import 'package:flutter/material.dart';
import 'package:flutter_settings/models/settings_list_item.dart';
import 'package:flutter_settings/widgets/SettingsSection.dart';
import 'package:flutter_settings/widgets/SettingsSelectionList.dart';

class SettingsView extends StatelessWidget {
  var fontItemList = <SettingsSelectionItem<int>>[
    SettingsSelectionItem<int>(0, "System Default"),
    SettingsSelectionItem<int>(1, "Nanum Gothic")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SafeArea(
          child: ListView(
        children: <Widget>[
          SettingsSection(
            title: Text('Appearance'),
            settingsChildren: [
              // ignore: missing_required_param
              SettingsSelectionList<int>(
                  context: context,
                  items: fontItemList,
                  title: 'Font',
                  onSelect: (value, index) {
                    debugPrint("You have selected " + value.text.toString());
                  })
            ],
          )
        ],
      )),
    );
  }
}
