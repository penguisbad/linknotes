import 'package:flutter/material.dart';
import 'package:linknotes/pages/folders.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/menu.dart';
import 'package:linknotes/widgets/changetitledialog.dart';
import 'package:linknotes/widgets/confirmdeletedialog.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';

class EditIncrementerPage extends StatefulWidget {

  final IncrementerNote note;

  const EditIncrementerPage({super.key, required this.note});

  @override
  State<EditIncrementerPage> createState() => _EditIncrementerState();

}

class _EditIncrementerState extends State<EditIncrementerPage> {

  late IncrementerNote _note;
  final _menuOpen = ValueNotifier(false);
  late TextEditingController _controller;
  bool? _addedToFolder;
  var _folders = <Folder>[];

  @override
  void initState() {
    super.initState();
    _note = widget.note.clone();
    _controller = TextEditingController(text: '${_note.value}');
    _controller.addListener(() { 
      _note.value = int.tryParse(_controller.text) ?? 0;
    });
    (() async {
      _folders = await getFolders();
      setState(() {
        _addedToFolder = _folders.where((f) => f.noteIds.contains(_note.id)).isNotEmpty;
      });
    })();
  }

  @override
  void dispose() {
    _menuOpen.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context, _note)),
        title: Center(child: Text(_note.title, style: Theme.of(context).textTheme.displayMedium!)),
        actions: [
          IconButton(
            onPressed: () => setState(() => _menuOpen.value = !_menuOpen.value),
            icon: Icon(_menuOpen.value ? Icons.close : Icons.more_vert, color: Theme.of(context).primaryColor)
          ),
          const SizedBox(width: 10.0)
        ]
      ),
      body: Stack(
        children: [
          ContentContainer(child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                onPressed: () => setState(() {
                  _note.value--;
                  _controller.text = '${_note.value}';
                }),
                icon: Icon(Icons.remove, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 10.0),
              SizedBox(width: 100.0, child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall!
              )),
              const SizedBox(width: 10.0),
              IconButton(
                onPressed: () => setState(() {
                  _note.value++;
                  _controller.text = '${_note.value}';
                }),
                icon: Icon(Icons.add, color: Theme.of(context).primaryColor)
              )
            ])
          )),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: Menu(
              isOpen: _menuOpen,
              options: [
                'Link',
                'Change title',
                '${_note.isAddedToDashboard ? 'Remove from' : 'Add to'} dashboard',
                '${_addedToFolder ?? false ? 'Remove from' : 'Add to' } folder',
                'Delete note'
              ],
              icons: [
                Icon(Icons.link, color: Theme.of(context).primaryColor),
                Icon(Icons.title, color: Theme.of(context).primaryColor),
                Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
                Icon(Icons.folder, color: Theme.of(context).primaryColor),
                Icon(Icons.delete, color: Theme.of(context).primaryColor)
              ],
              onSelected: (index) async {
                if (index == 1) {
                  showDialog(
                    context: context,
                    builder: (_) => ChangeTitleDialog(onTitleChanged: (value) => setState(() {
                      _note.title = value;
                    }))
                  );
                } else if (index == 2) {
                  setState(() {
                    _note.isAddedToDashboard = !_note.isAddedToDashboard;
                  });
                } else if (index == 3) {
                  if (_addedToFolder == null) {
                    return;
                  }
                  _folders = await updateFolders(
                    folders: _folders,
                    noteId: _note.id,
                    addedToFolder: _addedToFolder!,
                    getFolder: () async => await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const FoldersPage(selectingFolder: true),
                      fullscreenDialog: true
                    ))
                  );
                  setState(() {
                    _addedToFolder = !_addedToFolder!;
                  });
                  saveFolders(folders: _folders);
                } else if (index == 4) {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmDeleteDialog(
                      title: _note.title,
                      onDelete: () => Navigator.pop(context),
                    )
                  );
                }
              },
            )
          )
        ],
      )
    ));
  }

}