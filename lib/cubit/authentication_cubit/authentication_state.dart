part of 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
  @override
  List<Object> get props => [];
}

class AuthenticationUpdating extends AuthenticationState {
  const AuthenticationUpdating();
  @override
  List<Object> get props => [];
}

class AuthenticationUpdated extends AuthenticationState {
  const AuthenticationUpdated();
  @override
  List<Object> get props => [];
}

class AuthenticationError extends AuthenticationState {
  const AuthenticationError({this.error = ''});
  final String error;
  @override
  List<Object> get props => [error];
}
