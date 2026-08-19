import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'onesignal_config.dart';

/// Initializes the OneSignal SDK and keeps its externalId in sync with the
/// signed-in Firebase user, so a reminder can be targeted at an account
/// (via [ReminderService]) instead of a raw device token.
class OneSignalService {
  Future<void> initialize() async {
    OneSignal.initialize(OneSignalConfig.appId);
    await OneSignal.Notifications.requestPermission(true);
  }

  Future<void> loginUser(String uid) => OneSignal.login(uid);

  Future<void> logoutUser() => OneSignal.logout();
}
