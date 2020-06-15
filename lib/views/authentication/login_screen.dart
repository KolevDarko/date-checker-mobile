import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/dependencies/dependency_assembler.dart';
import 'package:date_checker_app/repository/auth_repository.dart';
import 'package:date_checker_app/views/authentication/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Најава'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
      ),
      body: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(
            authRepository: dependencyAssembler.get<AuthRepository>()),
        child: LoginForm(),
      ),
    );
  }
}
