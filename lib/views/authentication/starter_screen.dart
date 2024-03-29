import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets/splash_screen.dart';
import 'package:date_checker_app/views/authentication/login_screen.dart';
import 'package:date_checker_app/views/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoggedOutBloc, LoggedOutState>(
        listener: (context, state) {
          if (state is IsLoggedOut) {
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).appBarTheme.color,
                content: Text('Успешно се одјавивте'),
              ),
            );
          }
        },
        child: Builder(
          builder: (BuildContext context) {
            return BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                if (state is AuthenticationInitial) {
                  return SplashScreen();
                } else if (state is AuthenticationFailure) {
                  return LoginScreen();
                } else if (state is AuthenticationSuccess) {
                  _saveBatchWarnings(context);
                  return HomePage();
                }
                return Container();
              },
            );
          },
        ),
      ),
    );
  }

  _saveBatchWarnings(BuildContext context) {
    BlocProvider.of<ProductSyncBloc>(context).add(SyncProductData());
    BlocProvider.of<ProductBloc>(context).add(FetchAllProducts());
    BlocProvider.of<BatchWarningBloc>(context).add(AllBatchWarnings());
    BlocProvider.of<ProductBatchBloc>(context)
      ..add(SyncProductBatchData())
      ..add(AllProductBatch());
  }
}
