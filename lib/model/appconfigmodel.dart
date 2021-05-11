import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_logger/simple_logger.dart';

class AppConfigModel extends ChangeNotifier {
  // Constant
  static const String DEFAULT_DOCUMENT_PATH = 'docviewer';
  Completer<bool> loadCompleted = Completer<bool>();
  bool _isUpdated = false;

  AppConfigModel() {
    _init();
  }

  // define class
  var _fontList = ['System', 'NanumGothic'];
  List<String> get fontList {
    return _fontList;
  }

  int _fontIndex = 0;
  String get fontName {
    return _fontList[_fontIndex];
  }

  int get fontIndex {
    return _fontIndex;
  }

  set fontIndex(int fontindex) {
    if (fontindex < 0) return;
    if (fontindex >= _fontList.length) return;

    _fontIndex = fontindex;
    updateData();
  }

  String _targetPath;
  String get targetPath {
    return _targetPath;
  }

  set targetPath(String path) {
    _targetPath = path;
    updateData();
  }

  bool _hideBottomNaviBar;
  bool get hideBottomNaviBar {
    return _hideBottomNaviBar;
  }

  set hideBottomNaviBar(bool hide) {
    _hideBottomNaviBar = hide;
    updateData();
  }

  void _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fontIndex = (prefs.get('fontindex') ?? 0);
    _targetPath = (prefs.get('targetpath'));
    _hideBottomNaviBar = (prefs.get('hidebottomnavibar') ?? false);

    loadCompleted.complete(true);
    notifyListeners();
  }

  void updateData() {
    _isUpdated = true;
    notifyListeners();
  }

  void saveSettings() async {
    if (_isUpdated) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('fontindex', _fontIndex);
      prefs.setString('targetpath', _targetPath);
      prefs.setBool('hidebottomnavibar', _hideBottomNaviBar);

      final logger = SimpleLogger();
      logger.info("save settings");
    }

    _isUpdated = false;
  }
}
