import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Background location service that sends GPS coordinates every 3 seconds
/// even when the app is minimized or closed.
class BackgroundLocationService {
  static const String _baseUrl = 'https://api.japexim.co.in/';
  static const String _updateLocationEndpoint = 'api/tracking/location';

  /// Initialize the background service. Call this once in main().
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'agro_location_tracking',
        initialNotificationTitle: 'BABA Agro',
        initialNotificationContent: 'Tracking your location...',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  /// Start tracking with the given credentials
  static Future<void> startTracking({
    required String userId,
    required String authToken,
  }) async {
    final service = FlutterBackgroundService();

    // Pass credentials to the background isolate
    service.invoke('start_tracking', {
      'userId': userId,
      'authToken': authToken,
    });

    // Start the service if not already running
    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
      // Small delay to let service start, then send data
      await Future.delayed(const Duration(milliseconds: 500));
      service.invoke('start_tracking', {
        'userId': userId,
        'authToken': authToken,
      });
    }
  }

  /// Stop tracking
  static Future<void> stopTracking() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke('stop_tracking');
    }
  }

  /// Check if the service is currently running
  static Future<bool> isRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}

// ── Background isolate entry point ──────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> _onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  Timer? locationTimer;
  StreamSubscription<Position>? positionSubscription;
  Position? lastPosition;
  String? userId;
  String? authToken;
  bool isTracking = false;
  bool isUpdating = false;

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  Future<void> performLocationUpdate() async {
    if (!isTracking) {
      debugPrint(
        '[BackgroundLocationService] performLocationUpdate skipped: isTracking is false',
      );
      return;
    }
    if (userId == null || userId!.isEmpty) {
      debugPrint(
        '[BackgroundLocationService] performLocationUpdate skipped: userId is empty',
      );
      return;
    }
    if (authToken == null || authToken!.isEmpty) {
      debugPrint(
        '[BackgroundLocationService] performLocationUpdate skipped: authToken is empty',
      );
      return;
    }
    if (isUpdating) return;
    isUpdating = true;

    try {
      Position? position = lastPosition;
      if (position == null) {
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (_) {}
      }
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 3),
          );
        } catch (_) {}
      }

      if (position != null &&
          position.latitude != 0.0 &&
          position.longitude != 0.0) {
        lastPosition = position;
        final lat = position.latitude;
        final lng = position.longitude;
        final timestamp = DateTime.now().toUtc().toIso8601String();

        final success = await _sendLocationUpdate(
          userId: userId!,
          authToken: authToken!,
          latitude: lat,
          longitude: lng,
          timestamp: timestamp,
        );

        debugPrint(
          '[BackgroundLocationService] Location sent ($lat, $lng) success: $success',
        );
      } else {
        debugPrint('[BackgroundLocationService] Location fix unavailable');
      }
    } catch (e) {
      debugPrint('[BackgroundLocationService] Location update error: $e');
    } finally {
      isUpdating = false;
    }
  }

  // Listen for start tracking command from the main app
  service.on('start_tracking').listen((event) {
    if (event != null) {
      userId = event['userId'] as String?;
      authToken = event['authToken'] as String?;
      isTracking = true;

      debugPrint(
        '[BackgroundLocationService] Start tracking - userId: $userId',
      );

      // Update notification
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'BABA Agro',
          content: 'Tracking your location...',
        );
      }

      // Start continuous position listener to keep location warm
      positionSubscription?.cancel();
      try {
        positionSubscription =
            Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 0,
              ),
            ).listen(
              (Position pos) {
                lastPosition = pos;
              },
              onError: (e) {
                debugPrint('[BackgroundLocationService] Stream error: $e');
              },
            );
      } catch (e) {
        debugPrint('[BackgroundLocationService] Stream init error: $e');
      }

      // Immediate first update
      performLocationUpdate();

      // Cancel existing timer and start new one with 3 second interval
      locationTimer?.cancel();
      locationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
        if (!isTracking || userId == null || authToken == null) {
          timer.cancel();
          return;
        }
        performLocationUpdate();
      });
    }
  });

  // Listen for stop tracking command
  service.on('stop_tracking').listen((event) {
    debugPrint('[BackgroundLocationService] Stop tracking');
    isTracking = false;
    positionSubscription?.cancel();
    positionSubscription = null;
    lastPosition = null;
    locationTimer?.cancel();
    locationTimer = null;
    service.stopSelf();
  });

  // Listen for stop service
  service.on('stopService').listen((event) {
    isTracking = false;
    positionSubscription?.cancel();
    positionSubscription = null;
    lastPosition = null;
    locationTimer?.cancel();
    locationTimer = null;
    service.stopSelf();
  });
}

/// Send location update directly via HTTP (no GetX in background isolate)
Future<bool> _sendLocationUpdate({
  required String userId,
  required String authToken,
  required double latitude,
  required double longitude,
  required String timestamp,
}) async {
  try {
    final uri = Uri.parse(
      '${BackgroundLocationService._baseUrl}${BackgroundLocationService._updateLocationEndpoint}',
    );
    final body = jsonEncode({
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'time': timestamp,
    });

    final authHeader = authToken.startsWith('Bearer ')
        ? authToken
        : 'Bearer $authToken';

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
      },
      body: body,
    );

    debugPrint(
      '[BackgroundLocationService] POST updateLocationApi -> Status: ${response.statusCode}, Body: ${response.body}',
    );

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    debugPrint('[BackgroundLocationService] HTTP error: $e');
    return false;
  }
}

// iOS background handler
@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  // DartPluginRegistrant.ensureInitialized();
  return true;
}
