import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'auth/auth_repository.dart';
import 'core/di/injector.dart';
import 'core/notifications/onesignal_service.dart';
import 'data/local/task_hive_adapter.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(TaskHiveAdapter());

  await configureAppDependencies();
  await getIt<AuthRepository>().initialize();
  await getIt<OneSignalService>().initialize();

  runApp(const App());
}
