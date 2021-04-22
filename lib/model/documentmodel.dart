import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'information.dart';
import 'datamanager.dart';

enum SortType {
  Date,
  Title,
}

class DocumentModel extends ChangeNotifier {
  final String descfilename = "_docviewer_info.json";
  final String icondirname = "_icons";
  final String subdirname = "docviewer";

  Directory targetPath;

  DataManager _dataManager = DataManager();
  Map<String, Image> icons = {};

  String selectedKey = "";
  Set<String> filters = Set<String>();
  List<String> filteredfiles = [];

  SortType sortType = SortType.Date;
  int sortOrder = 1;

  DocumentModel() {
    updateInfo(false);
  }

  Map<String, InfoFolder> getFolders() {
    return _dataManager.folders;
  }

  Map<String, InfoFile> getFiles() {
    return _dataManager.files;
  }

  Future<Directory> _getTargetPath() async {
    if (Platform.isAndroid) {
      bool isgranted = await Permission.storage.request().isGranted;
      if (isgranted) {
        final extdocdirpath =
            await ExtStorage.getExternalStoragePublicDirectory(
                ExtStorage.DIRECTORY_DOCUMENTS);
        return Directory('$extdocdirpath/$subdirname').create(recursive: true);
      }
    } else if (Platform.isWindows) {
      final appdocdir = await getApplicationDocumentsDirectory();
      return Directory('${appdocdir.path}/$subdirname').create(recursive: true);
    }

    return null;
  }

  void updateInfo(bool forceUpdate) async {
    targetPath = await _getTargetPath();
    if (targetPath == null) return;

    debugPrint("TargetPath : $targetPath");

    var descfilepath = path.join(targetPath.path, descfilename);

    final descfile = File(descfilepath);
    if (descfile.existsSync() && forceUpdate == false) {
      loadJsonFromFile(descfilepath);
    } else {
      updateDirectory(targetPath);
      writeJsonToFile(descfilepath);
    }

    final iconpath = path.join(targetPath.path, icondirname);
    icons.clear();

    // 폴더 아이콘 로드
    var folders = _dataManager.folders;
    for (var folderkey in folders.keys) {
      icons.putIfAbsent(folderkey, () {
        var imagepath = path.join(iconpath, "$folderkey.png");
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

  void loadJsonFromFile(filename) {
    bool result = _dataManager.loadJsonFromFile(filename);
    debugPrint("$filename loaded : $result");
  }

  void writeJsonToFile(filename) {
    _dataManager.writeJsonToFile(filename);
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
    notifyListeners();
    debugPrint("update and notify");
  }

  bool isLock() {
    return _dataManager.isLock();
  }
}
