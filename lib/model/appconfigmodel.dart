import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigModel extends ChangeNotifier {
  // Constant
  static const String DEFAULT_DOCUMENT_PATH = 'docviewer';
  Completer<bool> loadCompleted = Completer<bool>();

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
    updateModel();
  }

  String _targetPath;
  String get targetPath {
    return _targetPath;
  }

  set targetPath(String path) {
    _targetPath = path;
    updateModel();
  }

  void _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fontIndex = (prefs.get('fontindex') ?? 0);
    _targetPath = (prefs.get('targetpath'));

    loadCompleted.complete(true);
    notifyListeners();
  }

  void updateModel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('fontindex', _fontIndex);
    prefs.setString('targetpath', _targetPath);

    notifyListeners();
  }
}
