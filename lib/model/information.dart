import 'package:sprintf/sprintf.dart';

class InfoFile {
  String folder;

  String filename;
  String title;
  String desc;

  DateTime datetime;
  String datetimeString;

  String _key;

  InfoFile(this.folder, this.filename, this.title, {this.desc, this.datetime}) {
    if (datetime != null) {
      datetimeString = makeTimeString(datetime);
    }
    _updateKey();
  }

  String getkey() {
    return _key;
    // return "$folder:$filename";
  }

  void _updateKey() {
    _key = "$folder:$filename";
  }

  InfoFile.fromJson(Map<String, dynamic> json)
      : folder = json['folder'],
        filename = json['filename'],
        title = json['title'],
        desc = json['desc'],
        datetimeString = json['datetime'] {
    final zerotime = DateTime(0);
    if (datetimeString != null) {
      datetime = DateTime.tryParse(datetimeString);
    } else {
      datetime = zerotime;
      datetimeString = makeTimeString(datetime);
    }

    _updateKey();
  }

  Map<String, dynamic> toJson() => {
        'folder': folder,
        'filename': filename,
        'title': title,
        'desc': desc,
        'created': datetimeString,
      };

  static String makeTimeString(DateTime time) {
    var timeString = sprintf("%i-%02i-%02i %02i:%02i",
        [time.year, time.month, time.day, time.hour, time.minute]);
    return timeString;
  }
}

class InfoFolder {
  String path;
  String title;

  InfoFolder(this.path, this.title);

  InfoFolder.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        title = json['title'];

  Map<String, dynamic> toJson() => {
        'path': path,
        'title': title,
      };
}