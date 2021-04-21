import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/documentmodel.dart';
import 'documentview.dart';
import 'myhomepage.dart';

void main() {
  // Future<Directory> appDocDir = getApplicationDocumentsDirectory();
  // appDocDir.then((value) => {stdout.writeln(value.path)});

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
                '/viewer': (context) => DocumentView()
              };

              WidgetBuilder builder = routes[settings.name];
              return MaterialPageRoute(builder: (ctx) => builder(ctx));
            }));
  }
}
