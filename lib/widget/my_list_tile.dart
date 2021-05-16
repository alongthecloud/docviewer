import 'package:flutter/material.dart';
import 'package:simple_logger/simple_logger.dart';

// ignore: must_be_immutable
class MyListTile extends StatelessWidget {
  final Image header;

  String parent;
  String title;
  String time;
  String desc;
  String tags;
  Function onTap;
  Function onLongPress;

  MyListTile(title, parent,
      {this.header,
      this.time,
      this.desc,
      this.tags,
      this.onTap,
      this.onLongPress}) {
    this.title = title;
    this.parent = parent;

    const String EMPTY = "";

    this.time = (this.time ?? EMPTY);
    this.tags = (this.tags ?? EMPTY);
    this.desc = (this.desc ?? EMPTY);
  }

  @override
  Widget build(BuildContext context) {
    var logger = SimpleLogger();
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      onLongPress: () {
        onLongPress?.call();
      },
      child: Container(
          padding: EdgeInsets.fromLTRB(9.0, 5.0, 9.0, 5.0),
          child: Row(children: [
            Container(
                width: 50,
                height: 50,
                child: ClipOval(
                  child: header,
                )),
            Expanded(
                child: Container(
                    padding: EdgeInsets.fromLTRB(9.0, 6.0, 9.0, 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Text(parent,
                                    style: TextStyle(fontSize: 16.0))),
                            SizedBox(
                                child: Text(time,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey[600]))),
                          ],
                        ),
                        Container(
                            padding: EdgeInsets.only(right: 3.0, top: 5.0),
                            child: Text(title,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.clip)),
                        Container(
                            padding: EdgeInsets.only(right: 3.0, top: 3.0),
                            child: Text(desc,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey),
                                overflow: TextOverflow.clip))
                      ],
                    ))),
            Container(
                width: 10,
                child: Text(tags,
                    textAlign: TextAlign.right, style: TextStyle(fontSize: 10)))
          ])),
    );
  }
}
