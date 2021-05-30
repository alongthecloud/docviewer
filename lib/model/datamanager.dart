import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:simple_logger/simple_logger.dart';

import 'information.dart';
import 'package:path/path.dart' as path;

class DataManager {
  final Set<String> extset = {".htm", ".html", ".txt"};

  Map<String, InfoFolder> folders = {};
  Map<String, InfoFile> files = {};
  bool locked = false;
  int allFilesCount = 0;

  Map<String, InfoTags> desces = {};

  void updateFromDirectory(targetPath) {
    // 한 계층의 디렉토리만 검색한다.
    var subDir = targetPath.listSync(recursive: false);

    List<Directory> dirlist = [];
    Set<String> undirset = Set<String>.from(folders.keys);

    for (var dir in subDir) {
      if (dir is! Directory) continue;
      var folderBasename = path.basename(dir.path);
      // . 과 _로 시작되는 것은 거른다.
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
    allFilesCount = 0;

    for (var dir in dirlist) {
      var subfiles = dir.listSync(recursive: false);
      var folderBasename = path.basename(dir.path);

      for (var subfile in subfiles) {
        var filepath = subfile.path;
        var filename = path.basename(filepath);
        var ext = path.extension(filepath);

        // extset 에 정의된 확장자만 사용
        if (extset.contains(ext)) {
          File f = File(filepath);
          FileStat fs = f.statSync();
          DateTime mdtime = fs.modified;
          var fileinfo = InfoFile(
              folderBasename, path.join(folderBasename, filename), filename,
              datetime: mdtime);

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

          assert(folders.containsKey(folderBasename) == true);
          var folder = folders[folderBasename];
          folder.count++;
          allFilesCount++;
        }
      }
    }

    files.removeWhere((key, fileinfo) {
      var filekey = fileinfo.getkey();
      return !fileset.contains(filekey);
    });
  }

  bool loadInfoJsonFromFile(filename) {
    var f = File(filename);
    if (!f.existsSync()) return false;

    var text = f.readAsStringSync();
    var jsonobj = jsonDecode(text);

    folders = {};
    files = {};

    var foldersobj = jsonobj['folders'];
    for (var obj in foldersobj) {
      var folder = InfoFolder.fromJson(obj);
      if (folder.path == null) continue;
      var folderBasename = path.basenameWithoutExtension(folder.path);

      folders.putIfAbsent(folderBasename, () => folder);
    }

    allFilesCount = 0;
    var filesobj = jsonobj['files'];
    for (var obj in filesobj) {
      var fileinfo = InfoFile.fromJson(obj);
      files.putIfAbsent(fileinfo.getkey(), () => fileinfo);

      var folderBasename = fileinfo.folder;

      assert(folders.containsKey(folderBasename) == true);
      var folder = folders[folderBasename];
      folder.count++;
      allFilesCount++;
    }

    var lockobj = jsonobj['lock'];
    locked = lockobj == null ? false : lockobj as bool;

    return true;
  }

  Future<bool> writeInfoJsonToFile(File wf) async {
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

    await wf.create();

    String jsonText;
    if (kDebugMode) {
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      jsonText = encoder.convert(root);
    } else {
      jsonText = jsonEncode(root);
    }

    await wf.writeAsString(jsonText);

    var logger = SimpleLogger();
    logger.info(
        "$wf.path saved (folder:${folderTable.length}, files:${fileTable.length}");

    return true;
  }

  bool loadDescFromJson(filename) {
    var f = File(filename);
    if (!f.existsSync()) return false;

    var text = f.readAsStringSync();
    var jsonobj = jsonDecode(text);

    desces = {};

    var tagsobj = jsonobj['tags'];
    tagsobj.forEach((k, v) {
      var tags = InfoTags.fromJson(v);
      if (tags.bookmark != 0) desces.putIfAbsent(k, () => tags);
    });

    return true;
  }

  void writeDescToJson(File wf) async {
    await wf.create();

    Map<String, dynamic> root = {
      'tags': desces,
    };

    String jsonText;
    if (kDebugMode) {
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      jsonText = encoder.convert(root);
    } else {
      jsonText = jsonEncode(root);
    }

    await wf.writeAsString(jsonText);

    var logger = SimpleLogger();
    logger.info("$wf.path saved");
  }
}
