import 'dart:io';

import 'package:docviewer/model/information.dart';
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
  String _title;
  String _htmlText = "";

  Widget _bottomButtons;
  FlutterWebviewPlugin flutterWebviewPlugin;

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS || Platform.isAndroid) {
      flutterWebviewPlugin = FlutterWebviewPlugin();
    }

    var model = Provider.of<DocumentModel>(context, listen: false);
    updateTargetPath(model);

    final List<Widget> footerButtons = [
      TextButton(
        child: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          if (model.nextSelected()) {
            updateTargetPath(model);
            setState(() {
              _htmlText = "";
            });
            if (flutterWebviewPlugin != null) {
              flutterWebviewPlugin.reloadUrl(Uri.file(_targetPath).toString());
            }
          }
        },
      ),
      TextButton(
        child: Icon(
          Icons.arrow_forward,
        ),
        onPressed: () {
          if (model.prevSelected()) {
            updateTargetPath(model);
            setState(() {
              _htmlText = "";
            });
            if (flutterWebviewPlugin != null) {
              flutterWebviewPlugin.reloadUrl(Uri.file(_targetPath).toString());
            }
          }
        },
      ),
    ];

    if (!model.appconfigmodel.hideBottomNaviBar) {
      _bottomButtons = Row(
          mainAxisAlignment: MainAxisAlignment.end, children: footerButtons);
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (flutterWebviewPlugin != null) {
      flutterWebviewPlugin.dispose();
      flutterWebviewPlugin = null;
    }
  }

  void updateTargetPath(DocumentModel model) {
    var folders = model.getFolders();
    InfoFile fileInfo = model.getSelectedFileInfo();
    Directory targetPath = model.targetPath;
    if (fileInfo != null) {
      _targetPath = path.join(
          targetPath.path, fileInfo.filename); // fileInfo.folder, 를 제거.
      _title = "${folders[fileInfo.folder].title} : ${fileInfo.title} ";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (flutterWebviewPlugin != null) {
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
        title: Text(_title, style: TextStyle(fontSize: 22)),
        gradient: LinearGradient(colors: [Colors.lightBlue, Colors.purple]),
      ),
      bottomNavigationBar: _bottomButtons,
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
      htmlViewWidget = Center(child: Text('Loading ...'));
    } else {
      htmlViewWidget = SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: HtmlWidget(_htmlText, baseUrl: Uri.file(_targetPath)));
    }

    return Scaffold(
      appBar: NewGradientAppBar(
        title: Text(_title),
        gradient: LinearGradient(colors: [Colors.lightBlue, Colors.purple]),
      ),
      body: htmlViewWidget,
      bottomNavigationBar: _bottomButtons,
    );
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
