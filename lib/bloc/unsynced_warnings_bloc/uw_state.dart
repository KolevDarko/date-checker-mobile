import 'package:date_checker_app/database/models.dart';
import 'package:equatable/equatable.dart';

abstract class UnsyncedWarningState extends Equatable {
  const UnsyncedWarningState();

  @override
  List<Object> get props => [];
}

class UnsyncedWarningsLoading extends UnsyncedWarningState {}

class UnsyncedWarningsLoaded extends UnsyncedWarningState {
  final List<BatchWarning> unsyncWarnings;

  UnsyncedWarningsLoaded({this.unsyncWarnings});

  @override
  List<Object> get props => [unsyncWarnings];
}
