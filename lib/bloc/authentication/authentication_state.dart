import 'package:date_checker_app/database/models.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
}

class AuthenticationInitial extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class AuthenticationSuccess extends AuthenticationState {
  final User loggedUser;

  const AuthenticationSuccess({this.loggedUser});

  @override
  List<Object> get props => [loggedUser];

  // @override
  // String toString() =>
  //     'AuthenticationSuccess { displayName: ${loggedUser.firstName} }';
}

class AuthenticationFailure extends AuthenticationState {
  @override
  List<Object> get props => [];
}
