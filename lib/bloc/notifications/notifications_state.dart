abstract class NotificationState {
  const NotificationState();
}

class EmptyNotification extends NotificationState {
  const EmptyNotification();
}

class DisplayNotification extends NotificationState {
  final String message;

  DisplayNotification({this.message});
}

class DisplayErrorNotification extends NotificationState {
  final String error;

  DisplayErrorNotification({this.error});
}
