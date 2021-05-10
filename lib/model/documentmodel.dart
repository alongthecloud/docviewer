import 'dart:async';
import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:synchronized_lite/synchronized_lite.dart';

import 'appconfigmodel.dart';
import 'information.dart';
import 'datamanager.dart';

enum SortType {
  Date,
  Title,
}

class DocumentModel extends ChangeNotifier {
  final _lockInfofileSave = Lock();
  final _lockDescfileSave = Lock();

  Timer _timerDescFileSave;

  final String infofilename = "_docviewer_info.json";
  final String descfilename = "_docviewer_desc.json";
  final String icondirname = "_icons";

  Directory targetPath;
  String _infofilepath;
  String _descfilepath;

  DataManager _dataManager = DataManager();
  Map<String, Image> icons = {};

  String selectedKey = "";
  Set<String> filters = Set<String>();
  List<String> filteredfiles = [];

  SortType sortType = SortType.Date;
  int sortOrder = 1;

  final AppConfigModel appconfigmodel;

  DocumentModel(this.appconfigmodel);

  Map<String, InfoFolder> getFolders() {
    return _dataManager.folders;
  }

  Map<String, InfoFile> getFiles() {
    return _dataManager.files;
  }

  Map<String, InfoTags> getTags() {
    return _dataManager.desces;
  }

  Future<Directory> _getTargetPath() async {
    Directory targetDirectory;
    String subdirname = appconfigmodel.targetPath;

    if (Platform.isAndroid) {
      bool isgranted = await Permission.storage.request().isGranted;
      if (isgranted) {
        final extdocdirpath =
            await ExtStorage.getExternalStoragePublicDirectory(
                ExtStorage.DIRECTORY_DOCUMENTS);

        targetDirectory = Directory('$extdocdirpath/$subdirname');
      }
    } else if (Platform.isWindows) {
      final appdocdir = await getApplicationDocumentsDirectory();
      targetDirectory = Directory('${appdocdir.path}/$subdirname');
    }

    if (!targetDirectory.existsSync())
      return null;
    else
      return targetDirectory;
  }

  void updateInfo(bool rebuild) async {
    var logger = SimpleLogger();

    targetPath = await _getTargetPath();
    if (targetPath == null) return;

    logger.info("TargetPath : $targetPath");

    _infofilepath = path.join(targetPath.path, infofilename);
    _descfilepath = path.join(targetPath.path, descfilename);

    final infofile = File(_infofilepath);
    if (infofile.existsSync() && rebuild == false) {
      loadInfoJsonFromFile();
    } else {
      updateDirectory(targetPath);
      writeInfoJsonToFile();
    }

    final descfile = File(_descfilepath);
    if (descfile.existsSync()) {
      loadDescFromFile();
    }

    final iconpath = path.join(targetPath.path, icondirname);
    icons.clear();

    // 폴더 아이콘 로드
    var folders = _dataManager.folders;
    for (var folderkey in folders.keys) {
      icons.putIfAbsent(folderkey, () {
        var imagepath = path.join(iconpath, "$folderkey.jpg");
        Image image = loadImageFromPath(imagepath);
        return image;
      });
    }

    updateFilterList(null);
    updateModel();
  }

  Image loadImageFromPath(imagepath) {
    var f = File(imagepath);
    if (f.existsSync() == false) return null;

    return Image.file(f);
  }

  void updateDirectory(targetPath) {
    _dataManager.updateFromDirectory(targetPath);
  }

  void loadInfoJsonFromFile() {
    var logger = SimpleLogger();

    bool result = _dataManager.loadInfoJsonFromFile(_infofilepath);
    logger.info("$_infofilepath loaded : $result");
  }

  void loadDescFromFile() {
    var logger = SimpleLogger();

    bool result = _dataManager.loadDescFromJson(_descfilepath);
    logger.info("$_descfilepath loaded : $result");
  }

  void writeInfoJsonToFile() async {
    return await _lockInfofileSave.synchronized(
        () => _dataManager.writeInfoJsonToFile(File(_infofilepath)));
  }

  void writeDescToFile() async {
    if (_timerDescFileSave != null) _timerDescFileSave.cancel();

    _timerDescFileSave = Timer(Duration(seconds: 10), () {
      _lockDescfileSave.synchronized(
          () => _dataManager.writeDescToJson(File(_descfilepath)));
    });
  }

  InfoFile getSelectedFileInfo() {
    var files = getFiles();

    if (selectedKey == null || selectedKey.isEmpty) return null;
    return files[selectedKey];
  }

  void updateFilterList(List<String> newfilters) {
    filteredfiles.clear();
    filters.clear();

    if (newfilters != null) filters.addAll(newfilters);

    var files = _dataManager.files;
    for (var file in files.values) {
      if (filters.length == 0 || filters.contains(file.folder)) {
        filteredfiles.add(file.getkey());
      }
    }

    sortFilteredFiles();
  }

  void sortFilteredFiles() {
    var files = _dataManager.files;

    var sortByDateTime = (InfoFile a, InfoFile b) {
      var sa = a.datetime;
      var sb = b.datetime;

      return sb.compareTo(sa) * sortOrder;
    };

    var sortByTitle = (InfoFile a, InfoFile b) {
      var sa = a.title;
      var sb = b.title;

      return sb.compareTo(sa) * sortOrder;
    };

    switch (sortType) {
      case SortType.Date:
        filteredfiles.sort((a, b) {
          var fa = files[a];
          var fb = files[b];

          var cp = sortByDateTime(fa, fb);
          return cp != 0 ? cp : sortByTitle(fa, fb);
        });

        break;
      case SortType.Title:
        filteredfiles.sort((a, b) {
          var fa = files[a];
          var fb = files[b];

          var cp = sortByTitle(fa, fb);
          return cp != 0 ? cp : sortByDateTime(fa, fb);
        });
        break;
    }

    updateModel();
  }

  void updateModel() {
    var logger = SimpleLogger();
    notifyListeners();
    logger.info("update and notify");
  }

  bool isRebuildLock() {
    return _dataManager.locked;
  }
}
