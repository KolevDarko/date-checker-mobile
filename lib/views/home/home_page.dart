import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/custom_widgets/route_animation.dart';
import 'package:date_checker_app/views/authentication/starter_screen.dart';
import 'package:date_checker_app/views/product_batch/add_edit_product_batch.dart';
import 'package:date_checker_app/views/product_batch/all_product_batch.dart';
import 'package:date_checker_app/views/product_warning/all_product_warnings.dart';
import 'package:date_checker_app/views/products/products_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0;
  BuildContext scaffoldContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            bottom: TabBar(
              onTap: (int currentTabIndex) {
                setState(() {
                  _currentTabIndex = currentTabIndex;
                });
              },
              tabs: [
                Tab(icon: Text('Пратки')),
                Tab(icon: Text('Истекување')),
                Tab(icon: Text("Производи")),
              ],
            ),
            title: Text('Табови'),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  BlocProvider.of<LoggedOutBloc>(context).add(
                    LogOutPressed(),
                  );
                },
              )
            ],
          ),
          body: BlocListener<NotificationsBloc, NotificationState>(
            listener: (context, state) {
              if (state is DisplayNotification) {
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.green,
                    content: Text(state.message),
                  ),
                );
              } else if (state is DisplayErrorNotification) {
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.red,
                    content: Text(state.error),
                  ),
                );
              }
            },
            child: Builder(
              builder: (BuildContext context) {
                return TabBarView(
                  children: [
                    ProductBatchTable(),
                    BatchWarningTable(),
                    ProductsTable(),
                  ],
                );
              },
            ),
          ),
          floatingActionButton: customFloatingButton(_currentTabIndex),
        ),
      ),
    );
  }

  FloatingActionButton customFloatingButton(int _currentTabIndex) {
    switch (_currentTabIndex) {
      case 0:
        {
          return FloatingActionButton(
            onPressed: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              Navigator.of(context).push(
                createRoute(AddOrEditProductBatchView()),
              );
            },
            child: Icon(Icons.add),
          );
        }
        break;
      case 1:
        {
          return FloatingActionButton(
            onPressed: () async {
              BlocProvider.of<SyncBatchWarningBloc>(context)
                  .add(SyncBatchWarnings());
            },
            child: Icon(Icons.refresh),
          );
        }
        break;
      case 2:
        {
          return FloatingActionButton(
            onPressed: () {
              BlocProvider.of<ProductSyncBloc>(context).add(SyncProductData());
            },
            child: Icon(Icons.refresh),
          );
        }
    }
    return null;
  }
}
