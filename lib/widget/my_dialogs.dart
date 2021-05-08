import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyInputDialog {
  final bool touchDismissible;
  final bool backDismissible;

  final Function(String) onConfirm;
  final String titleText;
  final String descText;
  final String hintText;

  String _inputValue;

  MyInputDialog(
      {this.touchDismissible,
      this.backDismissible,
      this.onConfirm,
      this.titleText,
      this.descText,
      this.hintText});

  Future<void> show(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          List<Widget> titleWidgets = [
            Text(titleText, style: TextStyle(fontWeight: FontWeight.bold))
          ];
          if (descText != null) {
            titleWidgets.add(SizedBox(height: 12));
            titleWidgets.add(Text(descText,
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)));
          }

          return AlertDialog(
            title: Column(children: titleWidgets),
            content: TextField(
              onChanged: (value) {
                _inputValue = value;
              },
              decoration: InputDecoration(hintText: hintText),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  if (onConfirm != null) {
                    onConfirm(_inputValue);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
