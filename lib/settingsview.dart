import 'package:flutter/material.dart';
import 'package:flutter_settings/models/settings_list_item.dart';
import 'package:flutter_settings/widgets/SettingsInputField.dart';
import 'package:flutter_settings/widgets/SettingsSection.dart';
import 'package:flutter_settings/widgets/SettingsSelectionList.dart';

import 'package:provider/provider.dart';
import 'model/appconfigmodel.dart';

class SettingsView extends StatelessWidget {
  List<SettingsSelectionItem<int>> fontItemList = [];

  @override
  Widget build(BuildContext context) {
    var appconfigmodel = Provider.of<AppConfigModel>(context, listen: false);

    if (fontItemList.length == 0) {
      int itemIndex = 0;
      for (var fontname in appconfigmodel.fontList) {
        fontItemList.add(SettingsSelectionItem<int>(itemIndex++, fontname));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SafeArea(
          child: ListView(
        children: <Widget>[
          SettingsSection(title: Text('System'), settingsChildren: [
            SettingsInputField(
              dialogButtonText: 'Confirm',
              title: 'Document path',
              caption: appconfigmodel.targetPath ?? "",
              onPressed: (value) {
                var text = value.toString();
                if (text != null && text.isNotEmpty) {
                  appconfigmodel.targetPath = text;
                }
              },
              context: context,
            ),
          ]),
          SettingsSection(
            title: Text('Appearance'),
            settingsChildren: [
              // ignore: missing_required_param
              SettingsSelectionList<int>(
                  context: context,
                  chosenItemIndex: appconfigmodel.fontIndex,
                  items: fontItemList,
                  title: 'Font',
                  caption: appconfigmodel.fontName,
                  onSelect: (value, index) {
                    appconfigmodel.fontIndex = index;
                  })
            ],
          )
        ],
      )),
    );
  }
}
