import 'package:date_checker_app/bloc/bloc.dart';

abstract class LoggedOutState {
  const LoggedOutState();
}

class IsNotLoggedOut extends LoggedOutState {}

class LoggingOutLoading extends LoggedOutState {}

class IsLoggedOut extends LoggedOutState {}
