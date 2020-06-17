import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoggedOutBloc extends Bloc<LoggedOutEvent, LoggedOutState> {
  final AuthenticationBloc authBloc;

  LoggedOutBloc({this.authBloc});
  @override
  LoggedOutState get initialState => IsNotLoggedOut();

  @override
  Stream<LoggedOutState> mapEventToState(LoggedOutEvent event) async* {
    if (event is LogOutPressed) {
      yield IsLoggedOut();
      authBloc.add(AuthenticationLoggedOut());
    }
  }
}
