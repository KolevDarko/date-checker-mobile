import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
}

class AddNewNotification extends NotificationsEvent {
  final String message;

  AddNewNotification({this.message});

  @override
  List<Object> get props => [message];
}
