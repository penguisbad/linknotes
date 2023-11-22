import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/widgets/notesview.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/menu.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/changetitledialog.dart';
import 'package:linknotes/widgets/confirmdeletedialog.dart';
import 'package:linknotes/pages/selectnote.dart';
import 'package:linknotes/database.dart';

class ViewFolderPage extends StatefulWidget {

  final Folder folder;

  const ViewFolderPage({super.key, required this.folder});

  @override
  State<ViewFolderPage> createState() => _ViewFolderState();

}

class _ViewFolderState extends State<ViewFolderPage> {

  late Folder _folder;
  List<Note>? _notes;
  final _menuOpen = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _folder = widget.folder.clone();
    (() async {
      var retrievedNotes = await getNotes();
      if (!mounted) return;
      setState(() {
        _notes = retrievedNotes;
      });
    })();
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context, _folder)),
        title: Center(child: Text(_folder.title, style: Theme.of(context).textTheme.displayMedium!)),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _menuOpen.value = !_menuOpen.value;
            }),
            icon: Icon(_menuOpen.value ? Icons.close : Icons.more_vert, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 10.0)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_notes == null) return;

          final selectedNote = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => SelectNotePage(notes: _notes!, alreadySelectedIds: _folder.noteIds,),
            fullscreenDialog: true
          ));
          if (!mounted || selectedNote == null) return;
          setState(() {
            _folder.noteIds.add(selectedNote.id);
          });
          
        },
        child: Icon(Icons.add, color: Theme.of(context).primaryColor)
      ),
      body: Stack(children: [
        ContentContainer(
          child: _notes != null ? ListView(
            children: [
              const SizedBox(height: 10.0),
              NotesView(
                notes: _notes!,
                filter: (note) => _folder.noteIds.contains(note.id),
                onNoteUpdated: (note) async {
                  final folders = await getFolders();
                  if (folders.where((f) => f.noteIds.contains(note.id)).isEmpty) {
                    setState(() {
                      _folder.noteIds.remove(note.id);
                    });
                  }
                },
                onNoteDeleted: (note) {
                  setState(() {
                    _folder.noteIds.remove(note.id);
                  });
                },
              )
            ],
          ) : SizedBox.square(
            dimension: 50.0,
            child: LoadingIndicator(
              indicatorType: Indicator.circleStrokeSpin,
              colors: [Theme.of(context).hintColor],
            ),
          )
        ),
        Positioned(
          right: 10.0,
          top: 10.0,
          child: Menu(
            isOpen: _menuOpen,
            options: const [
              'Change title',
              'Add all to dashboard',
              'Remove all from dashboard',
              'Delete folder'
            ],
            icons: [
              Icon(Icons.title, color: Theme.of(context).primaryColor),
              Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
              Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
              Icon(Icons.delete, color: Theme.of(context).primaryColor)
            ],
            onSelected: (index) {
              if (index == 0) {
                showDialog(context: context, builder: (_) => ChangeTitleDialog(
                  onTitleChanged: (value) => setState(() {
                    _folder.title = value;
                  }),
                ));
              } else if (index == 1) {
                if (_notes == null) return;
                for (var i = 0; i < _notes!.length; i++) {
                  if (_folder.noteIds.contains(_notes![i].id)) {
                    _notes![i].isAddedToDashboard = true;
                  }
                }
                saveNotes(notes: _notes!);
              } else if (index == 2) {
                if (_notes == null) return;
                for (var i = 0; i < _notes!.length; i++) {
                  if (_folder.noteIds.contains(_notes![i].id)) {
                    _notes![i].isAddedToDashboard = false;
                  }
                }
                saveNotes(notes: _notes!);
              } else {
                showDialog(context: context, builder: (_) => ConfirmDeleteDialog(
                  title: _folder.title,
                  onDelete: () => Navigator.pop(context), 
                ));
              }
            },
          ),
        )
      ])
    ));
  }
}