abstract class LoggedOutState {
  const LoggedOutState();
}

class IsNotLoggedOut extends LoggedOutState {}

class LoggingOutLoading extends LoggedOutState {}

class IsLoggedOut extends LoggedOutState {}
