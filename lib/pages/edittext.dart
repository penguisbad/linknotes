import 'package:flutter/material.dart';
import 'package:linknotes/database.dart';
import 'package:linknotes/pages/folders.dart';
import 'package:linknotes/pages/link.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/nobackgroundtextfield.dart';
import 'package:linknotes/widgets/menu.dart';
import 'package:linknotes/widgets/changetitledialog.dart';
import 'package:linknotes/widgets/confirmdeletedialog.dart';
import 'package:linknotes/model.dart';

class EditTextPage extends StatefulWidget {

  final TextNote note;

  const EditTextPage({super.key, required this.note});

  @override
  State<EditTextPage> createState() => _EditTextState();

}

class _EditTextState extends State<EditTextPage> {

  late TextNote _note;
  late TextEditingController _controller;
  final _menuOpen = ValueNotifier(false);
  bool? _addedToFolder;
  var _folders = <Folder>[];

  @override
  void initState() {
    super.initState();
    _note = widget.note.clone();

    _controller = TextEditingController(text: _note.text);
    _controller.addListener(() {
      _note.text = _controller.text;
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
    _controller.dispose();
    _menuOpen.dispose();
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
            onPressed: () {
              _menuOpen.value = !_menuOpen.value;
              setState(() {
                
              });
            },
            icon: Icon(_menuOpen.value ? Icons.close : Icons.more_vert, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 10.0,)
        ]
      ),
      body: Stack(
        children: [
          ContentContainer(
            child: ListView(children: [
              const SizedBox(height: 20.0),
              NoBackgroundTextField(placeholder: 'type here', multiline: true, controller: _controller,),
            ])
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: Menu(
              isOpen: _menuOpen,
              options: [
                'Link',
                'Change title',
                '${_note.isAddedToDashboard ? 'Remove from' : 'Add to'} dashboard',
                '${_addedToFolder ?? false ? 'Remove from' : 'Add to'} folder',
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
                
                if (index == 0) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => LinkPage(link: Link(
                      source: _note,
                      linkType: LinkType.combine,
                      combineNames: false
                    )),
                    fullscreenDialog: true
                  ));
                } else if (index == 1) {
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
                      onDelete: () {
                        Navigator.pop(context);
                      },
                    )
                  );
                }
              },
            ),
          )
        ]
      )
    ));
  }

}