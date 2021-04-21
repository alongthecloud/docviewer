import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyListTile extends StatelessWidget {
  final Image header;

  String parent;
  String title;
  String tag;
  String desc;
  Function onTap;

  MyListTile(title, parent, {this.header, this.tag, this.desc, this.onTap}) {
    this.title = title;
    this.parent = parent;
    if (this.tag == null) this.tag = "";
    if (this.desc == null) this.desc = "";
  }

  @override
  Widget build(BuildContext context) {
    final double contextRateWidth = MediaQuery.of(context).size.width - 192;
    return InkWell(
      onTap: () {
        if (onTap != null) onTap();
      },
      child: Container(
          padding: EdgeInsets.fromLTRB(9.0, 3.0, 6.0, 3.0),
          child: Row(children: [
            Container(
                padding: EdgeInsets.all(2),
                width: 42,
                height: 42,
                child: ClipOval(
                  child: header,
                )),
            Container(
                padding: EdgeInsets.fromLTRB(9.0, 3.0, 6.0, 3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: contextRateWidth,
                            child:
                                Text(parent, style: TextStyle(fontSize: 13.0))),
                        Container(
                            child: Text(tag,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600]))),
                      ],
                    ),
                    Container(
                        padding: new EdgeInsets.only(right: 16.0),
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.fade)),
                    Container(
                        child: Text(desc,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w200),
                            overflow: TextOverflow.clip))
                  ],
                )),
          ])),
    );
  }
}
