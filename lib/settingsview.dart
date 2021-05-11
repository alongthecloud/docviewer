import 'package:flutter/material.dart';
import 'package:flutter_settings/models/settings_list_item.dart';
import 'package:flutter_settings/util/SettingsConstants.dart';
import 'package:flutter_settings/widgets/SettingsCheckBox.dart';
import 'package:flutter_settings/widgets/SettingsInputField.dart';
import 'package:flutter_settings/widgets/SettingsSection.dart';
import 'package:flutter_settings/widgets/SettingsSelectionList.dart';

import 'package:provider/provider.dart';
import 'model/appconfigmodel.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  List<SettingsSelectionItem<int>> fontItemList = [];

  @override
  void deactivate() {
    super.deactivate();

    var appconfigmodel = Provider.of<AppConfigModel>(context, listen: false);
    appconfigmodel.saveSettings();
  }

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
                  }),
              SettingsCheckBox(
                title: 'Hide bottom navigation',
                onPressed: (bool value) {
                  appconfigmodel.hideBottomNaviBar = value;
                },
                value: appconfigmodel.hideBottomNaviBar,
                type: CheckBoxWidgetType.Switch,
              ),
            ],
          )
        ],
      )),
    );
  }
}
