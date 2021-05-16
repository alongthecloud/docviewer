import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:simple_logger/simple_logger.dart';

import 'model/documentmodel.dart';
import 'model/information.dart';
import 'widget/expandable_group_widget.dart';
import 'widget/my_list_tile.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _filelistScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // _treeViewController = ExpandedTileController();
  }

  @override
  void dispose() {
    // _treeViewController.dispose();
    super.dispose();
  }

  Widget _folderListView(context, DocumentModel model) {
    // Custom Text Widget function
    const TextStyle widgetTextStyle = TextStyle(fontSize: 16);
    Widget Function(String text, int count) customTextWidget =
        (String text, int count) {
      //return Text(text, style: TextStyle(fontSize: 16));
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(text, style: widgetTextStyle),
            Text(count.toString(), style: widgetTextStyle)
          ]);
    };

    var folderinfos = model.getFolders();
    final filterindices = model.filters;

    List<Widget> groupWidget = [];

    Color selectedColor = Colors.grey[300];

    // group list
    for (InfoFolder info in folderinfos.values) {
      var leadicon =
          model.icons.containsKey(info.path) ? model.icons[info.path] : null;
      groupWidget.add(Container(
          padding: EdgeInsets.all(2),
          child: ListTile(
              leading: Container(
                  width: 40, height: 40, child: ClipOval(child: leadicon)),
              title: customTextWidget(info.title, info.count),
              onTap: () {
                model.updateFilterList([info.path]);
                model.updateModel();
                Navigator.pop(context);
              },
              selected: filterindices.length != 0 &&
                  filterindices.contains(info.path),
              selectedTileColor: selectedColor)));
    }

    // additional  widgets
    List<Widget> appendWidget = [];
    appendWidget.add(SizedBox(height: 10));
    appendWidget.add(ListTile(
      leading: const Icon(Icons.refresh),
      title: Text('Rebuild'),
      subtitle: Text('rebuild file information'),
      onTap: model.isRebuildLock()
          ? null
          : () {
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                content: Text("Would you like to rebuild file informations?"),
                actions: [
                  TextButton(
                    child: Text("No"),
                    onPressed: () {
                      model.updateInfo(false);
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text("Yes"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      model.updateInfo(true);
                    },
                  ),
                ],
              );

              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
    ));

    appendWidget.add(ListTile(
      leading: const Icon(Icons.settings),
      title: Text('Settings'),
      onTap: () {
        Navigator.pushNamed(context, '/settings');
      },
    ));

    appendWidget.add(ListTile(
      leading: const Icon(Icons.info),
      title: Text('About'),
      onTap: () {
        Navigator.pushNamed(context, '/about');
      },
    ));

    int allFilesCount = model.getAllFilesCount();

    return ListView(children: [
      ListTile(
        title: customTextWidget('All', allFilesCount),
        onTap: () {
          model.updateFilterList(null);
          model.updateModel();
          Navigator.pop(context);
        },
        selected: filterindices.length == 0,
        selectedTileColor: selectedColor,
      ),
      ExpandableGroup(
          isExpanded: true,
          header: ListTile(title: Text('Folders')),
          items: groupWidget),
      Column(children: appendWidget)
    ]);
  }

  Widget _fileListView(context, DocumentModel model) {
    var logger = SimpleLogger();

    var folderinfos = model.getFolders();
    var fileinfos = model.getFiles();
    var tagsinfos = model.getTags();

    var listfiles = model.filteredfiles;

    return ListView.builder(
      controller: _filelistScrollController,
      itemCount: listfiles.length,
      itemBuilder: (context, index) {
        var filekey = listfiles[index];
        InfoFile curFileinfo = fileinfos[filekey];
        InfoTags curTagsinfo = tagsinfos[filekey];

        String foldername = folderinfos.containsKey(curFileinfo.folder)
            ? folderinfos[curFileinfo.folder].title
            : curFileinfo.folder;

        String bookmark = " ";
        if (curTagsinfo != null && curTagsinfo.bookmark != 0) {
          bookmark = '⭐';
        }

        return MyListTile(curFileinfo.title, foldername,
            header: model.icons[curFileinfo.folder],
            time: curFileinfo.datetimeString,
            desc: curFileinfo.desc,
            tags: bookmark, onTap: () {
          model.selectedIndex = index;
          Navigator.pushNamed(context, '/viewer');
        }, onLongPress: () {
          curTagsinfo = tagsinfos.update(filekey, (value) {
            value.bookmark = value.bookmark == 0 ? 1 : 0;
            return value;
          }, ifAbsent: () {
            return InfoTags(1);
          });

          setState(() {
            model.writeDescToFile();
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // var appconfigmodel = Provider.of<AppConfigModel>(context, listen: false);
    return Consumer<DocumentModel>(
      builder: (context, model, child) {
        var orderArrow = model.sortOrder < 0 ? '↑' : '↓';

        return Scaffold(
          key: scaffoldKey,
          appBar: new AppBar(
            actions: [
              PopupMenuButton(
                icon: Icon(Icons.more_horiz_rounded),
                onSelected: (newValue) {
                  if (model.sortType == newValue) {
                    model.sortOrder *= -1;
                  }

                  model.sortType = newValue;
                  model.sortFilteredFiles();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text("Sort By Date $orderArrow"),
                    value: SortType.Date,
                  ),
                  PopupMenuItem(
                    child: Text("Sort By Title $orderArrow"),
                    value: SortType.Title,
                  ),
                ],
              )
            ],
            title: InkWell(
              child: Text("Home"),
              onTap: () {
                _filelistScrollController.position
                    .moveTo(0, duration: Duration(milliseconds: 250));
              },
            ),
            elevation:
                defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          ),
          drawer: Drawer(
              child: Container(
                  padding: EdgeInsets.all(3),
                  child: _folderListView(context, model))),
          body: _fileListView(context, model),
        );
      },
    );
  }
}
