import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'local_notification_service.dart';

/// Wires up Firebase Cloud Messaging: requests permission, registers the
/// device token (stored on the user's Firestore doc so a future
/// server-side sender has somewhere to read it from), and surfaces
/// foreground messages as local notifications. No server currently sends
/// anything — this is the client-side half of FCM.
class FcmService {
  FcmService({required FirebaseMessaging messaging, required LocalNotificationService localNotifications})
      : _messaging = messaging,
        _localNotifications = localNotifications;

  final FirebaseMessaging _messaging;
  final LocalNotificationService _localNotifications;

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.showNow(
        title: notification.title ?? '',
        body: notification.body ?? '',
      );
    });
  }

  /// Fetches the current device token and stores it on `users/{uid}` so a
  /// server-side sender (e.g. a Cloud Function) could target this device.
  Future<void> registerTokenForUser(FirebaseFirestore firestore, String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await firestore.collection('users').doc(uid).set(
        {'fcmToken': token, 'fcmTokenUpdatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('FcmService: failed to register token: $e');
    }
  }
}

/// Must be a top-level (or static) function, and registered before runApp.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background/terminated-state messages with a `notification` payload are
  // displayed by the OS automatically; nothing to do here beyond letting
  // the message reach the FCM SDK. Data-only messages could be handled
  // here if/when a server-side sender is added.
}
