import 'package:equatable/equatable.dart';

abstract class LoggedOutEvent extends Equatable {
  const LoggedOutEvent();
  @override
  List<Object> get props => [];
}

class LogOutPressed extends LoggedOutEvent {
  const LogOutPressed();
}
