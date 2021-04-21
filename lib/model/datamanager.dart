import 'dart:convert';
import 'dart:io';
import 'information.dart';
import 'package:path/path.dart' as path;

class DataManager {
  final Set<String> extset = {".htm", ".html", ".txt"};

  Map<String, InfoFolder> folders = {};
  Map<String, InfoFile> files = {};

  bool _locked = false;
  bool isLock() {
    return _locked;
  }

  void updateFromDirectory(targetPath) {
    // 한 계층의 디렉토리만 검색한다.
    var subDir = targetPath.listSync(recursive: false);

    List<Directory> dirlist = [];
    Set<String> undirset = Set<String>.from(folders.keys);

    for (var dir in subDir) {
      if (dir is! Directory) continue;
      var folderBasename = path.basename(dir.path);
      if (folderBasename.startsWith(".") || folderBasename.startsWith("_"))
        continue;

      undirset.remove(folderBasename);
      dirlist.add(dir);

      folders.putIfAbsent(
          folderBasename, () => InfoFolder(folderBasename, folderBasename));
    }

    // 없어진 폴더를 지운다.
    for (var undir in undirset) {
      folders.remove(undir);
    }

    files.removeWhere((key, InfoFile value) {
      bool contained = undirset.contains(value.folder);
      return contained;
    });

    Set<String> fileset = Set<String>();

    for (var dir in dirlist) {
      var subfiles = dir.listSync(recursive: false);
      var folderBasename = path.basename(dir.path);

      for (var subfile in subfiles) {
        var filepath = subfile.path;
        var filename = path.basename(filepath);
        var ext = path.extension(filepath);

        // 확장자 필터, html과 txt 만 지원
        if (extset.contains(ext)) {
          File f = File(filepath);
          FileStat fs = f.statSync();
          DateTime mdtime = fs.modified;
          var fileinfo =
              InfoFile(folderBasename, filename, filename, datetime: mdtime);

          var filekey = fileinfo.getkey();
          files.update(filekey, (beforeFileinfo) {
            if (beforeFileinfo.datetime == fileinfo.datetime)
              return beforeFileinfo;
            else
              return fileinfo;
          }, ifAbsent: () {
            return fileinfo;
          });

          fileset.add(filekey);
        }
      }
    }

    files.removeWhere((key, fileinfo) {
      var filekey = fileinfo.getkey();
      return !fileset.contains(filekey);
    });
  }

  bool loadJsonFromFile(filename) {
    var f = File(filename);
    if (!f.existsSync()) return false;

    var text = f.readAsStringSync();
    var jsonobj = jsonDecode(text);

    folders = {};
    files = {};

    var foldersobj = jsonobj['folders'];
    for (var obj in foldersobj) {
      var folder = InfoFolder.fromJson(obj);
      var folderBasename = path.basenameWithoutExtension(folder.path);

      folders.putIfAbsent(folderBasename, () => folder);
    }

    var filesobj = jsonobj['files'];
    for (var obj in filesobj) {
      var fileinfo = InfoFile.fromJson(obj);
      files.putIfAbsent(fileinfo.getkey(), () => fileinfo);
    }

    var lockobj = jsonobj['lock'];
    if (lockobj == null)
      _locked = false;
    else
      _locked = lockobj as bool;

    return true;
  }

  bool writeJsonToFile(filename) {
    List<dynamic> folderTable = [];
    for (var folder in folders.values) {
      folderTable.add(folder.toJson());
    }

    List<dynamic> fileTable = [];
    for (var file in files.values) {
      fileTable.add(file.toJson());
    }

    Map<String, dynamic> root = {
      'folders': folderTable,
      'files': fileTable,
      'lock': false
    };

    var f = File(filename);
    f.createSync();
    f.writeAsStringSync(jsonEncode(root));

    print(
        "$filename saved (folder:${folderTable.length}, files:${fileTable.length}");

    return true;
  }
}
