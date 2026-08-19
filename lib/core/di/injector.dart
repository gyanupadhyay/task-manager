import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../auth/auth_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../data/connectivity/connectivity_service.dart';
import '../../data/local/local_task_source.dart';
import '../../data/remote/firestore_task_source.dart';
import '../../data/sync/sync_service.dart';
import '../../data/task_repository.dart';
import '../../features/tasks/bloc/task_filter/task_filter_cubit.dart';
import '../../features/tasks/bloc/task_list/task_list_bloc.dart';
import '../../models/task.dart';
import '../../sync/bloc/sync_cubit.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

const userScopeName = 'user';

/// App-wide singletons that live for the whole process lifetime.
void configureAppDependencies() {
  getIt
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<InternetConnection>(InternetConnection.new)
    ..registerLazySingleton<Dio>(buildDioClient)
    ..registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(connectivity: getIt(), internetConnection: getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(firebaseAuth: getIt(), googleSignIn: getIt()),
    )
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(authRepository: getIt())..add(const AuthSubscriptionRequested()),
    );
}

/// Registers everything that depends on the signed-in user's uid, inside a
/// dedicated get_it scope so it's cleanly torn down on sign-out. Safe to
/// call again for a different uid (pops any existing user scope first).
Future<void> configureUserScopedDependencies(String uid) async {
  if (getIt.currentScopeName == userScopeName) {
    await getIt.popScope();
  }
  await getIt.pushNewScopeAsync(
    scopeName: userScopeName,
    init: (scoped) async {
      final box = await Hive.openBox<Task>('tasks_$uid');
      scoped
        ..registerLazySingleton<Box<Task>>(() => box, dispose: (b) => b.close())
        ..registerLazySingleton<LocalTaskSource>(() => LocalTaskSource(scoped()))
        ..registerLazySingleton<FirestoreTaskSource>(
          () => FirestoreTaskSource(scoped<FirebaseFirestore>(), uid),
        )
        ..registerLazySingleton<SyncService>(
          () => SyncService(local: scoped(), remote: scoped()),
        )
        ..registerLazySingleton<TaskRepository>(
          () => TaskRepository(local: scoped(), remote: scoped(), syncService: scoped()),
        )
        ..registerLazySingleton<SyncCubit>(
          () => SyncCubit(
            connectivityService: scoped(),
            syncService: scoped(),
            localTaskSource: scoped(),
            firestoreTaskSource: scoped(),
          )..start(),
          dispose: (cubit) => cubit.close(),
        )
        ..registerLazySingleton<TaskListBloc>(
          () => TaskListBloc(repository: scoped())..add(const TaskListSubscriptionRequested()),
          dispose: (bloc) => bloc.close(),
        )
        ..registerLazySingleton<TaskFilterCubit>(
          TaskFilterCubit.new,
          dispose: (cubit) => cubit.close(),
        );
    },
  );
}

Future<void> disposeUserScopedDependencies() async {
  if (getIt.currentScopeName == userScopeName) {
    await getIt.popScope();
  }
}
