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
    on<_AuthUserChanged>(_onUserChanged);
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
