import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';

import 'model/documentmodel.dart';
import 'model/appconfigmodel.dart';
import 'initview.dart';
import 'documentview.dart';
import 'myhomepage.dart';
import 'aboutview.dart';
import 'settingsview.dart';

void main() {
  final logger = SimpleLogger();
  if (kReleaseMode) {
    logger.setLevel(Level.OFF);
  }

  runApp(ChangeNotifierProvider<AppConfigModel>(
      create: (_) {
        return AppConfigModel();
      },
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appconfigmodel = Provider.of<AppConfigModel>(context, listen: false);

    return ChangeNotifierProvider<DocumentModel>(create: (_) {
      return DocumentModel(appconfigmodel);
    }, child: Consumer<AppConfigModel>(builder: (context, model, child) {
      ThemeData apptheme;

      if (appconfigmodel.fontIndex != 0) {
        apptheme = ThemeData(
          fontFamily: appconfigmodel.fontName,
        );
      }

      return MaterialApp(
          theme: apptheme,
          title: 'Txt viewer',
          initialRoute: '/init',
          onGenerateRoute: (settings) {
            var routes = <String, WidgetBuilder>{
              '/': (context) => MyHomePage(),
              '/init': (context) => InitView(),
              '/viewer': (context) => DocumentView(),
              '/settings': (context) => SettingsView(),
              '/about': (context) => AboutView(),
            };

            WidgetBuilder builder = routes[settings.name];
            return MaterialPageRoute(builder: (ctx) => builder(ctx));
          });
    }));
  }
}
