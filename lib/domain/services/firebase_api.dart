import 'dart:convert';
import 'dart:io';

import 'package:agro_app/app/app.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseApi {
  static String? currentUuid;
  static bool isVideo = false;

  /// Cache for pending notification navigation when app is launching or authenticating
  static Map<String, dynamic>? _pendingNotificationPayload;
  static DateTime? _lastHandledTime;
  static String? _lastHandledSignature;

  static Future<void> initNotification() async {
    // Request permission (especially important for iOS and Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // On iOS, configure foreground presentation options to show heads-up notifications natively
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // 1. Foreground Message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Foreground message received: ${message.notification?.title ?? message.data['title']}");

      if (Platform.isAndroid) {
        _showNotification(message);
      }
    });

    // 2. Background Message Opened listener (when app is opened from background via system FCM banner)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 [FCM Background Opened] message.data: ${message.data}");
      handleNotificationData(message.data);
    });

    // 3. Terminated / Cold Start check via Firebase Messaging
    await checkFCMInitialMessage();
  }

  // 🔧 Extracted helper to show local popup notification
  static void _showNotification(RemoteMessage message) {
    final Map<String, String> payloadMap = {};
    message.data.forEach((key, value) {
      payloadMap[key] = value?.toString() ?? '';
    });

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: UniqueKey().hashCode,
        channelKey: 'high_importance_channel',
        title: message.notification?.title ?? message.data['title']?.toString() ?? '',
        body: message.notification?.body ?? message.data['body']?.toString() ?? message.data['message']?.toString() ?? '',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        payload: payloadMap,
      ),
    );
  }

  /// Check if app was opened from terminated / killed state via FCM
  static Future<void> checkFCMInitialMessage() async {
    try {
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null && initialMessage.data.isNotEmpty) {
        print("🔔 [FCM Terminated Mode] Initial message found: ${initialMessage.data}");
        _pendingNotificationPayload = Map<String, dynamic>.from(initialMessage.data);
      }
    } catch (e) {
      print("Error checking FCM initial message: $e");
    }
  }

  /// Check if app was opened from terminated / killed state via AwesomeNotifications
  static Future<void> checkAwesomeInitialAction() async {
    try {
      final action = await AwesomeNotifications().getInitialNotificationAction();
      if (action != null && action.payload != null && action.payload!.isNotEmpty) {
        print("🔔 [Awesome Terminated Mode] Initial action found: ${action.payload}");
        _pendingNotificationPayload = Map<String, dynamic>.from(action.payload!);
      }
    } catch (e) {
      print("Error checking Awesome initial action: $e");
    }
  }

  /// Check for any initial notification from cold start (Called from Splash or App start)
  static Future<void> onAppTerminateMode() async {
    await checkAwesomeInitialAction();
    await checkFCMInitialMessage();
  }

  /// Compatibility wrapper for existing callers
  static void handleNavigationOnNotification(RemoteMessage message) {
    handleNotificationData(message.data);
  }

  static void handleNavigationOnNotificationBackground(RemoteMessage message) {
    handleNotificationData(message.data);
  }

  static Future<void> initilizeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'its demo Notification',
          channelDescription: 'Demo Notification',
          ledColor: ColorsValue.appColor,
          importance: NotificationImportance.Max, // ✅ Max importance for heads-up alert
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
          defaultPrivacy: NotificationPrivacy.Public, // ✅ Show on lock screen
        ),
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'agro_location_tracking',
          channelName: 'Agro Location Tracking',
          channelDescription:
              'Notification channel for tracking user location during shifts.',
          ledColor: ColorsValue.appColor,
          importance: NotificationImportance.Low,
          channelShowBadge: false,
          playSound: false,
          onlyAlertOnce: true,
          defaultPrivacy: NotificationPrivacy.Public,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel',
          channelGroupName: 'Group 1',
        ),
      ],
      debug: true,
    );

    // Request permissions for Awesome Notifications
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onNotificationActionReceived,
    );

    // Check if app was launched via AwesomeNotifications action (Killed state)
    await checkAwesomeInitialAction();

    // Initialize Firebase listeners (foreground/background/permissions)
    await initNotification();

    // Register background message isolate handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationActionReceived(
    ReceivedAction receivedAction,
  ) async {
    // ✅ This fires when user taps a notification (Foreground, Background, or Killed)
    print("🔔 [Awesome Notification Tap] Payload: ${receivedAction.payload}");
    final payload = receivedAction.payload;
    if (payload != null && payload.isNotEmpty) {
      handleNotificationData(Map<String, dynamic>.from(payload));
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();

    if (Platform.isAndroid) {
      _showNotification(message);
    }
  }

  /// Entry point to handle notification payload across all application modes
  static void handleNotificationData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return;

    final type = extractNotificationType(data);
    if (type == null || type.isEmpty) {
      print("🔔 No valid notification type found in data: $data");
      return;
    }

    // Debounce duplicate clicks within 2 seconds
    final signature = "$type-${data['id'] ?? data['_id'] ?? data['entityId'] ?? data['entity_id'] ?? data.toString()}";
    final now = DateTime.now();
    if (_lastHandledSignature == signature &&
        _lastHandledTime != null &&
        now.difference(_lastHandledTime!).inSeconds < 2) {
      print("🔔 Duplicate notification action debounced: $signature");
      return;
    }

    // Check if app is still at splash, auth, or cold-starting
    final currentRoute = Get.currentRoute;
    final isSplashOrAuth = currentRoute.isEmpty ||
        currentRoute == Routes.splashScreen ||
        currentRoute == Routes.authScreen ||
        currentRoute == Routes.otpScreen ||
        currentRoute == Routes.registerScreen;

    if (isSplashOrAuth) {
      print("🔔 App is currently at '$currentRoute'. Enqueuing notification payload for execution after login/load.");
      _pendingNotificationPayload = Map<String, dynamic>.from(data);
      return;
    }

    // App is running and authenticated: execute navigation immediately
    _lastHandledSignature = signature;
    _lastHandledTime = now;
    _pendingNotificationPayload = null;

    navigateBasedOnType(type, fullData: data);
  }

  /// Process any pending notification payload that was queued during app startup/splash
  static void processPendingNotification() {
    if (_pendingNotificationPayload == null) return;

    final payload = Map<String, dynamic>.from(_pendingNotificationPayload!);
    _pendingNotificationPayload = null;

    final type = extractNotificationType(payload);
    if (type == null || type.isEmpty) return;

    print("🔔 [Pending Notification] Executing navigation for type: $type");
    final signature = "$type-${payload['id'] ?? payload['_id'] ?? payload['entityId'] ?? payload['entity_id'] ?? payload.toString()}";
    _lastHandledSignature = signature;
    _lastHandledTime = DateTime.now();

    // Small delay to ensure the main dashboard has mounted smoothly
    Future.delayed(const Duration(milliseconds: 300), () {
      navigateBasedOnType(type, fullData: payload);
    });
  }

  /// Clear pending notification (e.g. on logout or invalid session)
  static void clearPendingNotification() {
    _pendingNotificationPayload = null;
  }

  /// Helper to extract notification type from diverse payload shapes
  static String? extractNotificationType(Map<dynamic, dynamic>? data) {
    if (data == null || data.isEmpty) return null;

    // Check direct keys
    final directKeys = [
      'type',
      'Type',
      'notification_type',
      'notificationType',
      'screen',
      'screen_name',
      'screenName',
      'click_action',
      'entity',
      'entity_type',
      'category',
    ];

    for (var key in directKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final val = data[key].toString().trim();
        if (val.isNotEmpty) {
          return val;
        }
      }
    }

    // Case-insensitive key scan
    for (var entry in data.entries) {
      final k = entry.key.toString().toLowerCase().trim();
      if (k == 'type' || k == 'notification_type' || k == 'screen') {
        final val = entry.value?.toString().trim();
        if (val != null && val.isNotEmpty) {
          return val;
        }
      }
    }

    // Check nested 'data' or 'payload' map / JSON string
    if (data.containsKey('data')) {
      final nestedData = data['data'];
      if (nestedData is Map) {
        final extracted = extractNotificationType(nestedData);
        if (extracted != null) return extracted;
      } else if (nestedData is String && nestedData.startsWith('{')) {
        try {
          final decoded = json.decode(nestedData);
          if (decoded is Map) {
            final extracted = extractNotificationType(decoded);
            if (extracted != null) return extracted;
          }
        } catch (_) {}
      }
    }

    if (data.containsKey('payload')) {
      final nestedPayload = data['payload'];
      if (nestedPayload is Map) {
        final extracted = extractNotificationType(nestedPayload);
        if (extracted != null) return extracted;
      } else if (nestedPayload is String && nestedPayload.startsWith('{')) {
        try {
          final decoded = json.decode(nestedPayload);
          if (decoded is Map) {
            final extracted = extractNotificationType(decoded);
            if (extracted != null) return extracted;
          }
        } catch (_) {}
      }
    }

    return null;
  }

  /// Route to the appropriate screen based on notification type
  static void navigateBasedOnType(String typeStr, {Map<String, dynamic>? fullData}) {
    final type = typeStr.toLowerCase().trim();
    print("🔔 [Navigate on Notification] Routing for type: '$type'");

    switch (type) {
      case 'task':
      case 'tasks':
      case 'taskscreen':
      case 'tasks_screen':
        if (Get.currentRoute == Routes.tasksScreen) {
          if (Get.isRegistered<TasksController>()) {
            Get.find<TasksController>().fetchTasks(isRefresh: true);
          }
        } else {
          RouteManagement.goToTasksScreen();
        }
        break;

      case 'order':
      case 'orders':
      case 'orderscreen':
      case 'orders_screen':
        if (Get.currentRoute == Routes.ordersScreen) {
          // Already on orders screen
        } else {
          RouteManagement.goToOrdersScreen();
        }
        break;

      case 'customerorder':
      case 'customer_order':
      case 'customer_orders':
      case 'customerorderscreen':
      case 'customer_orders_screen':
        if (Get.currentRoute == Routes.customerOrdersScreen) {
          if (Get.isRegistered<CustomerOrdersController>()) {
            Get.find<CustomerOrdersController>().fetchAllCustomerOrders();
          }
        } else {
          RouteManagement.goToCustomerOrdersScreen();
        }
        break;

      case 'attendance':
      case 'attendancescreen':
        RouteManagement.goToAttendanceScreen();
        break;

      case 'leave':
      case 'leaves':
      case 'leavescreen':
        RouteManagement.goToLeaveScreen();
        break;

      case 'collection':
      case 'collections':
      case 'collectionscreen':
        RouteManagement.goToCollectionScreen();
        break;

      case 'expense':
      case 'expenses':
      case 'expensescreen':
        RouteManagement.goToExpenseScreen();
        break;

      case 'distributor':
      case 'distributors':
      case 'distributorsscreen':
        RouteManagement.goToDistributorsScreen();
        break;

      case 'customer':
      case 'customers':
      case 'customersscreen':
        RouteManagement.goToCustomersScreen();
        break;

      case 'product':
      case 'products':
      case 'productsscreen':
        RouteManagement.goToProductsScreen();
        break;

      case 'ledger':
      case 'ledgers':
      case 'ledgersscreen':
        RouteManagement.goToLedgersScreen();
        break;

      case 'profile':
      case 'profilescreen':
        RouteManagement.goToProfileScreen();
        break;

      case 'notification':
      case 'notifications':
      case 'notificationscreen':
      default:
        RouteManagement.goToNotificationScreen();
        break;
    }
  }
}
