import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:agro_app/app/app.dart';

class FirebaseApi {
  static String? currentUuid;
  static bool isVideo = false;

  Future<void> initNotification() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message.notification);

      if (Platform.isAndroid) {
        _showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNavigationOnNotificationBackground(message);
    });
  }

  // 🔧 Extracted helper to reuse in background handler too
  static void _showNotification(RemoteMessage message) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: UniqueKey().hashCode,
        channelKey: 'high_importance_channel',
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        // ✅ These two lines make it show as a heads-up popup
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        payload: message.data.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      ),
    );
  }

  static void onAppTerminateMode() {
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        handleNavigationOnNotification(message);
      }
    });
  }

  static void handleNavigationOnNotification(RemoteMessage message) {
    // 🔧 Add your navigation logic here, example:
    // final navigatorKey = App.navigatorKey; // use your global navigator key
    // navigatorKey.currentState?.pushNamed('/chat', arguments: message.data);
  }

  static void handleNavigationOnNotificationBackground(RemoteMessage message) {
    handleNavigationOnNotification(message);
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
          importance: NotificationImportance.Max, // ✅ Changed High → Max
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
          defaultPrivacy: NotificationPrivacy.Public, // ✅ Show on lock screen
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

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onNotificationActionReceived,
    );



    // ✅ Must be registered before any background work
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationActionReceived(
    ReceivedAction receivedAction,
  ) async {
    // ✅ This fires when user taps a notification — opens/brings app to front
    final payload = receivedAction.payload;
    if (payload != null) {
      handleNavigationOnNotification(RemoteMessage(data: payload));
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // ✅ Must initialize Firebase before doing anything in background isolate
    await Firebase.initializeApp();

    if (Platform.isAndroid) {
      _showNotification(message);
    }
  }
}
