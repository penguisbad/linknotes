import 'package:flutter/material.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/undodelete.dart';
import 'package:linknotes/widgets/drawer.dart';
import 'package:linknotes/pages/viewfolder.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';

typedef FolderCallback = void Function(Folder folder);

class FolderView extends StatelessWidget {

  final Folder folder;
  final FolderCallback onPressed;

  const FolderView({super.key, required this.folder, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onPressed(folder),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: const Color.fromRGBO(70, 70, 100, 1),
            width: 3.0
          )
        ),
        child: Row(children: [Expanded(child: Column(
          children: [
            Row(children: [
              const SizedBox(width: 5.0),
              Flexible(child: Text(folder.title, style: Theme.of(context).textTheme.displaySmall!)),
            ]),
            const SizedBox(height: 20.0),
            Row(children: [
              const SizedBox(width: 5.0),
              Text(folder.noteIds.length == 1 ? '1 note'
              : '${folder.noteIds.length} notes', style: Theme.of(context).textTheme.displaySmall!)
            ])
          ],
        ))])
      )
    );
  }
}

class FoldersPage extends StatefulWidget {

  final List<Folder>? folders;
  final bool selectingFolder;

  const FoldersPage({super.key, this.folders, required this.selectingFolder});

  @override
  State<FoldersPage> createState() => _FoldersState();

}

class _FoldersState extends State<FoldersPage> {

  var _column1Folders = [];
  var _column2Folders = [];
  late List<Folder> _folders;
  bool _loading = true;

  var _newFolderTitle = '';

  void _updateColumns() {
    _column1Folders = [];
    _column2Folders = [];
    var column1 = true;

    for (final folder in _folders) {
      if (column1) {
        _column1Folders.add(folder);
      } else {
        _column2Folders.add(folder);
      }
      column1 = !column1;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.folders == null) {
      (() async {
        var retrievedFolders = await getFolders();
        setState(() {
          _folders = retrievedFolders;
          _loading = false;
          _updateColumns();
        });
      })();
    } else {
      _folders = [...widget.folders!];
    }
   
  }

  void _viewFolder(Folder folder) async {
    final newFolder = await Navigator.push(context, MaterialPageRoute(
      builder: (_) => ViewFolderPage(folder: folder),
      fullscreenDialog: true
    ));

    if (!mounted) return;

    for (var i = 0; i < _folders.length; i++) {
      if (_folders[i].id == folder.id) {
        if (newFolder == null) {
          final deletedFolder = _folders[i];
          final deletedIndex = i;
          showUndoDelete(
            context: context,
            title: deletedFolder.title,
            onUndoDelete: () {
              setState(() {
                _folders.insert(deletedIndex, deletedFolder);
                _updateColumns();
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              saveFolders(folders: _folders);
            }
          );
        }
        setState(() {
          if (newFolder == null) {
            _folders.removeAt(i);
          } else {
            _folders[i] = newFolder;
          }
          _updateColumns();
        });
        saveFolders(folders: _folders);
        break;
      }
    }
  }

  void _onFolderPressed(folder) {
    if (widget.selectingFolder) {
      Navigator.pop(context, folder);
    } else {
      _viewFolder(folder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: widget.selectingFolder 
        ? LBackButton(onPressed: () => Navigator.pop(context))
        : const OpenDrawerButton(),
        title: Text(widget.selectingFolder ? 'Select folder' : 'Folders', style: Theme.of(context).textTheme.displayMedium!)
      ),
      drawer: const LDrawer(),
      floatingActionButton: widget.selectingFolder ? null : FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) => AlertDialog(
            title: Text('New folder', style: Theme.of(context).textTheme.displayMedium!),
            content: TextField(
              onChanged: (value) => _newFolderTitle = value,
              style: Theme.of(context).textTheme.displaySmall!,
              decoration: const InputDecoration(
                hintText: 'title'
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: Theme.of(context).textTheme.displaySmall!)
              ),
              ElevatedButton(
                onPressed: () {
                  final newFolder = Folder(title: _newFolderTitle, noteIds: []);
                  setState(() {
                    _folders.add(newFolder);
                    _updateColumns();
                  });
                  Navigator.pop(context);
                  _viewFolder(newFolder);
                },
                child: Text('Create', style: Theme.of(context).textTheme.displaySmall!)
              )
            ],
          ));
        },
        child: Icon(Icons.add, color: Theme.of(context).primaryColor)
      ),
      body: ContentContainer(
        child: !_loading ? ListView(
          children: [
            const SizedBox(height: 10.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(
                  children: (() {
                    var items = <Widget>[];
                    for (final folder in _column1Folders) {
                      items.add(FolderView(folder: folder, onPressed: _onFolderPressed));
                      items.add(const SizedBox(height: 10.0));
                    }
                    return items;
                  })(),
                )),
                const SizedBox(width: 10.0),
                Expanded(child: Column(
                  children: (() {
                    var items = <Widget>[];
                    for (final folder in _column2Folders) {
                      items.add(FolderView(folder: folder, onPressed: _onFolderPressed));
                      items.add(const SizedBox(height: 10.0));
                    }
                    return items;
                  })(),
                ))
              ],
            )
          ]
        ) : SizedBox.square(
          dimension: 50.0,
          child: LoadingIndicator(
            indicatorType: Indicator.circleStrokeSpin,
            colors: [Theme.of(context).hintColor],
          )
        )
      )
    ));
  }
}