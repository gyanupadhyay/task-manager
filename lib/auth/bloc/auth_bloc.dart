import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    // Must run strictly in order: a fast sign-out-then-sign-in emits a null
    // user followed by the new user in quick succession, and the default
    // concurrent transformer would let their get_it scope pop/push (and the
    // underlying Hive box close/open) race each other.
    on<_AuthUserChanged>(_onUserChanged, transformer: _sequential());
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authSubscription?.cancel();
    final completer = Completer<void>();
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      add(_AuthUserChanged(user));
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  Future<void> _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) async {
    final user = event.user;
    if (user == null) {
      await disposeUserScopedDependencies();
      emit(const AuthUnauthenticated());
      return;
    }
    // Ensure per-user local storage/repositories exist before declaring
    // the user authenticated, so screens built off AuthAuthenticated can
    // safely resolve user-scoped dependencies from get_it.
    await configureUserScopedDependencies(user.uid);
    emit(AuthAuthenticated(user));
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
      // Resulting AuthAuthenticated state arrives via the authStateChanges subscription.
    } catch (_) {
      emit(const AuthUnauthenticated(errorMessage: 'Sign-in failed. Please try again.'));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

/// Processes events one at a time, in order, waiting for each handler to
/// finish before starting the next — unlike bloc's default transformer,
/// which runs handlers concurrently.
EventTransformer<E> _sequential<E>() => (events, mapper) => events.asyncExpand(mapper);
