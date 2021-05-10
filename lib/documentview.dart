import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'model/documentmodel.dart';

class DocumentView extends StatefulWidget {
  @override
  _DocumentViewState createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  String _targetPath;
  String _filename;
  String _htmlText = "";

  @override
  void initState() {
    super.initState();

    var model = Provider.of<DocumentModel>(context, listen: false);
    var fileInfo = model.getSelectedFileInfo();
    Directory targetPath = model.targetPath;
    if (fileInfo != null) {
      // _basePath = path.join(targetPath.path, fileInfo.folder);
      _targetPath =
          path.join(targetPath.path, fileInfo.folder, fileInfo.filename);
      _filename = fileInfo.filename;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Platform.isAndroid) {
      return buildWidgetMobile();
    } else {
      // Windows 등 Flutter 내장 위젯으로 HTML을 그린다.
      return buildWidget();
    }
  }

  Widget buildWidgetMobile() {
    return WebviewScaffold(
      url: Uri.file(_targetPath).toString(),
      appBar: NewGradientAppBar(
          title: Text(_filename),
          gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlue])),
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
          color: Colors.blueGrey[50],
          child: const Center(
            child: Text('.....'),
          )),
    );
  }

  Widget buildWidget() {
    Widget htmlViewWidget;
    if (_htmlText.isEmpty) {
      loadHtmlFile();
      htmlViewWidget = Text('Loading ...');
    } else {
      htmlViewWidget = HtmlWidget(_htmlText, baseUrl: Uri.file(_targetPath));
    }

    return Scaffold(
        appBar: AppBar(title: Text(_filename)),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(10), child: htmlViewWidget));
  }

  void loadHtmlFile() async {
    if (_targetPath == null) return;

    final f = File(_targetPath);
    if (!f.existsSync()) return;

    String txt = await f.readAsString();

    setState(() {
      _htmlText = txt;
    });
  }
}
