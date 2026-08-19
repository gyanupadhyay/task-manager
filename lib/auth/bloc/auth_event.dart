part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

final class _AuthUserChanged extends AuthEvent {
  const _AuthUserChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user?.uid];
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
