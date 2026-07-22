import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
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
  DartPluginRegistrant.ensureInitialized();

  Timer? locationTimer;
  String? userId;
  String? authToken;
  bool isTracking = false;

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
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

      // Cancel existing timer and start new one
      locationTimer?.cancel();
      locationTimer = Timer.periodic(
        const Duration(seconds: 3),
        (timer) async {
          if (!isTracking || userId == null || authToken == null) {
            timer.cancel();
            return;
          }

          try {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 5),
            );

            final lat = position.latitude;
            final lng = position.longitude;

            if (lat != 0.0 && lng != 0.0) {
              final timestamp = DateTime.now().toUtc().toIso8601String();
              await _sendLocationUpdate(
                userId: userId!,
                authToken: authToken!,
                latitude: lat,
                longitude: lng,
                timestamp: timestamp,
              );
              debugPrint(
                '[BackgroundLocationService] Location sent: $lat, $lng',
              );
            }
          } catch (e) {
            debugPrint(
              '[BackgroundLocationService] Location update error: $e',
            );
          }
        },
      );
    }
  });

  // Listen for stop tracking command
  service.on('stop_tracking').listen((event) {
    debugPrint('[BackgroundLocationService] Stop tracking');
    isTracking = false;
    locationTimer?.cancel();
    locationTimer = null;
    service.stopSelf();
  });

  // Listen for stop service
  service.on('stopService').listen((event) {
    isTracking = false;
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

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: body,
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
  DartPluginRegistrant.ensureInitialized();
  return true;
}
