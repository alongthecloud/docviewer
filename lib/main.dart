import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/documentmodel.dart';
import 'documentview.dart';
import 'myhomepage.dart';
import 'aboutview.dart';
import 'settingsview.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) {
          return DocumentModel();
        },
        child: MaterialApp(
            theme: ThemeData(fontFamily: 'Nanum'),
            title: 'Txt viewer',
            initialRoute: '/',
            onGenerateRoute: (settings) {
              var routes = <String, WidgetBuilder>{
                '/': (context) => MyHomePage(),
                '/viewer': (context) => DocumentView(),
                '/settings': (context) => SettingsView(),
                '/about': (context) => AboutView(),
              };

              WidgetBuilder builder = routes[settings.name];
              return MaterialPageRoute(builder: (ctx) => builder(ctx));
            }));
  }
}
