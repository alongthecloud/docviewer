import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/appconfigmodel.dart';
import 'model/documentmodel.dart';
import 'widget/my_dialogs.dart';

class InitView extends StatefulWidget {
  @override
  _InitViewState createState() => _InitViewState();
}

class _InitViewState extends State<InitView> {
  Completer<String> documentPathComplete = Completer<String>();

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    var documentmodel = Provider.of<DocumentModel>(context, listen: false);
    var appconfigmodel = Provider.of<AppConfigModel>(context, listen: false);

    // 경로 설정이 완료되면 0.3 초를 기다린뒤 Home 으로 이동한다.
    documentPathComplete.future.then((value) {
      appconfigmodel.targetPath = value;
      appconfigmodel.saveSettings();
      documentmodel.updateInfo(false);
      Future.delayed(Duration(milliseconds: 200), () => Navigator.pop(context));
    });

    bool result = await appconfigmodel.loadCompleted.future;
    if (result) {
      var configTargetPath = appconfigmodel.targetPath;
      if (configTargetPath != null && configTargetPath.isNotEmpty) {
        documentPathComplete.complete(configTargetPath);
      } else {
        Future.delayed(Duration.zero, () => showDocumentPathInput(context));
      }
    }
  }

  void showDocumentPathInput(context) async {
    var dialog = MyInputDialog(
        touchDismissible: false,
        backDismissible: true,
        titleText: 'Input document path',
        descText:
            "setup the reference path to read the document. Please enter a folder located under the Documents folder. Default value is '${AppConfigModel.DEFAULT_DOCUMENT_PATH}'.",
        hintText: AppConfigModel.DEFAULT_DOCUMENT_PATH,
        onConfirm: (String text) {
          if (text == null || text.isEmpty)
            text = AppConfigModel.DEFAULT_DOCUMENT_PATH;

          documentPathComplete.complete(text);
        });

    return dialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: FutureBuilder<String>(
                future: documentPathComplete.future,
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text('Initialized ...');
                  } else {
                    return Text('Waiting ...');
                  }
                })));
  }
}
