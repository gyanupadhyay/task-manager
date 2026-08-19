import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/bloc/auth_bloc.dart';
import '../auth/presentation/sign_in_screen.dart';
import '../core/di/injector.dart';
import '../features/tasks/bloc/task_filter/task_filter_cubit.dart';
import '../features/tasks/bloc/task_list/task_list_bloc.dart';
import '../features/tasks/presentation/screens/add_edit_task_screen.dart';
import '../features/tasks/presentation/screens/task_detail_screen.dart';
import '../features/tasks/presentation/screens/task_list_screen.dart';
import '../models/task.dart';
import '../sync/bloc/sync_cubit.dart';

GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      if (authState is AuthInitial || authState is AuthLoading) {
        return location == '/' ? null : '/';
      }
      final signedIn = authState is AuthAuthenticated;
      if (!signedIn) {
        return location == '/sign-in' ? null : '/sign-in';
      }
      if (location == '/' || location == '/sign-in') {
        return '/tasks';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _SplashScreen()),
      GoRoute(path: '/sign-in', builder: (context, state) => const SignInScreen()),
      ShellRoute(
        builder: (context, state, child) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<TaskListBloc>()),
            BlocProvider.value(value: getIt<TaskFilterCubit>()),
            BlocProvider.value(value: getIt<SyncCubit>()),
          ],
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TaskListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const AddEditTaskScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    TaskDetailScreen(taskId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) =>
                        AddEditTaskScreen(initial: state.extra as Task?),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Bridges a [Stream] (the auth bloc's state stream) to go_router's
/// [Listenable]-based `refreshListenable`, so route redirects re-evaluate
/// whenever auth state changes.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
