import 'package:sprintf/sprintf.dart';

abstract class InfoBase {
  String getkey();

  InfoBase();
  InfoBase.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson();
}

class InfoFile implements InfoBase {
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

  void _updateKey() {
    _key = "$folder::$filename";
  }

  @override
  InfoFile.fromJson(Map<String, dynamic> json)
      : folder = json['folder'],
        filename = json['name'],
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

  @override
  Map<String, dynamic> toJson() => {
        'folder': folder,
        'name': filename,
        'title': title,
        'desc': desc,
        'datetime': datetimeString,
      };

  static String makeTimeString(DateTime time) {
    var timeString = sprintf("%i-%02i-%02i %02i:%02i:%02i",
        [time.year, time.month, time.day, time.hour, time.minute, time.second]);
    return timeString;
  }

  @override
  String getkey() {
    return _key;
  }
}

class InfoFolder implements InfoBase {
  // serialized
  String path;
  String title;
  // non-serialized
  int count = 0;

  InfoFolder(this.path, this.title);

  @override
  String getkey() {
    return path;
  }

  @override
  InfoFolder.fromJson(Map<String, dynamic> json)
      : path = json['name'],
        title = json['title'];

  @override
  Map<String, dynamic> toJson() => {
        'name': path,
        'title': title,
      };
}

class InfoTags extends InfoBase {
  int bookmark;

  InfoTags(this.bookmark);

  @override
  String getkey() {
    return 'tags';
  }

  @override
  InfoTags.fromJson(Map<String, dynamic> json)
      : bookmark = json['bookmark'] ?? 0;

  @override
  Map<String, dynamic> toJson() => {'bookmark': bookmark};
}
