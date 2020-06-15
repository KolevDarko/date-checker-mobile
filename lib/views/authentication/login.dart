import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets/splash_screen.dart';
import 'package:date_checker_app/views/authentication/data_sync.dart';
import 'package:date_checker_app/views/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          return BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state is AuthenticationInitial) {
                return SplashScreen();
              } else if (state is AuthenticationFailure) {
                return LoginScreen();
              } else if (state is AuthenticationSuccess) {
                return DataSync();
              }
            },
          );
        },
      ),
    );
  }
}
