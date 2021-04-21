import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import 'model/documentmodel.dart';

class DocumentView extends StatefulWidget {
  @override
  _DocumentViewState createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  String _targetPath;
  String _htmlText = "";

  @override
  void initState() {
    super.initState();

    var model = Provider.of<DocumentModel>(context, listen: false);
    var fileInfo = model.getSelectedFileInfo();
    Directory targetPath = model.targetPath;
    if (fileInfo != null) {
      _targetPath =
          path.join(targetPath.path, fileInfo.folder, fileInfo.filename);

      loadHtmlFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Viewer')),
        body: Container(
            padding: EdgeInsets.all(18),
            child: SingleChildScrollView(
                child: HtmlWidget(
              _getHtmlText(),
              customWidgetBuilder: (element) {
                if (element.localName == 'title') {
                  return SizedBox(height: 5);
                }
                return null;
              },
            ))));
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

  String _getHtmlText() {
    return _htmlText;
  }
}
