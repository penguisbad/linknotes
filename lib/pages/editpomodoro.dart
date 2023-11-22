import 'package:flutter/material.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';
import 'package:linknotes/pages/folders.dart';
import 'package:linknotes/pages/pomodorooptions.dart';
import 'package:linknotes/widgets/confirmdeletedialog.dart';
import 'package:linknotes/widgets/changetitledialog.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/menu.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/nobackgroundtextfield.dart';

class EditPomodoroPage extends StatefulWidget {

  final PomodoroNote note;

  const EditPomodoroPage({super.key, required this.note});

  @override
  State<EditPomodoroPage> createState() => _EditPomodoroState();  

}

class _EditPomodoroState extends State<EditPomodoroPage> {

  late PomodoroNote _note;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  final _menuOpen = ValueNotifier(false);
  bool? _addedToFolder;
  var _folders = <Folder>[];

  @override
  void initState() {
    super.initState();
    _note = widget.note.clone();
    _updateTextFields();
    
    (() async {
      _folders = await getFolders();
      setState(() {
        _addedToFolder = _folders.where((f) => f.noteIds.contains(_note.id)).isNotEmpty;
      });
    })();
    
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].dispose();
    }
    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].dispose();
    }
  }

  void _updateTextFields() {
    _disposeControllers();
    _controllers = [];
    _focusNodes = [];
    for (var i = 0; i < _note.tasks.length; i++) {
      var controller = TextEditingController(text: _note.tasks[i]);
      controller.addListener(() {
        _note.tasks[i] = controller.text;
      });
      _controllers.add(controller);

      _focusNodes.add(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context, _note)),
        title: Center(child: Text(_note.title, style: Theme.of(context).textTheme.displayMedium!)),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _menuOpen.value = !_menuOpen.value;
            }),
            icon: Icon(_menuOpen.value ? Icons.close : Icons.more_vert, color: Theme.of(context).primaryColor)
          ),
          const SizedBox(width: 10.0)
        ],
      ),
      body: Stack(children: [
        ContentContainer(child: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
              shadowColor: Colors.transparent
          ),
          child: ReorderableListView.builder(
            onReorderStart: (_) => setState(() {
              for (var i = 0; i < _focusNodes.length; i++) {
                _focusNodes[i].unfocus();
              }
            }),
            onReorder: ((oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final task = _note.tasks.removeAt(oldIndex);
              _note.tasks.insert(newIndex, task);
              _updateTextFields();
            }),
            header: const SizedBox(height: 20.0),
            itemCount: _note.tasks.length,
            itemBuilder: (context, index) => ListTile(
              key: Key('$index'),
              title: NoBackgroundTextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                placeholder: 'task',
              ),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                TextButton(
                  onPressed: () => setState(() {
                    _note.tasks.removeAt(index);
                    _updateTextFields();
                  }),
                  child: Icon(Icons.close, color: Theme.of(context).hintColor)
                ),
                ReorderableDragStartListener(
                  key: Key('$index'),
                  index: index,
                  child: Icon(Icons.drag_handle, color: Theme.of(context).hintColor)
                )
              ])
            ),
            footer: Center(child: SizedBox(
              width: 200.0,
              child: ElevatedButton.icon(
                onPressed: () => setState(() {
                  _note.tasks.add('');
                  _updateTextFields();
                }),
                icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
                label: Text('Add', style: Theme.of(context).textTheme.displaySmall!)
              )
            )),
          )
        )),
        Positioned(
          right: 10.0,
          top: 10.0,
          child: Menu(
            isOpen: _menuOpen,
            options: [
              'Link',
              'Change title',
              '${_note.isAddedToDashboard ? 'Remove from' : 'Add to'} dashboard',
              '${_addedToFolder ?? false ? 'Remove from' : 'Add to'} folder',
              'Options',
              'Delete note'
            ],
            icons: [
              Icon(Icons.link, color: Theme.of(context).primaryColor),
              Icon(Icons.title, color: Theme.of(context).primaryColor),
              Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
              Icon(Icons.folder, color: Theme.of(context).primaryColor),
              Icon(Icons.settings, color: Theme.of(context).primaryColor),
              Icon(Icons.delete, color: Theme.of(context).primaryColor)
            ],
            onSelected: (index) async {
              if (index == 1) {
                showDialog(context: context, builder: (_) => ChangeTitleDialog(
                  onTitleChanged: (value) => setState(() {
                    _note.title = value;
                  })
                ));
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
                final newNote = await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PomodoroOptionsPage(note: _note),
                  fullscreenDialog: true
                ));
                setState(() {
                  _note = newNote;
                });
              } else if (index == 5) {
                showDialog(context: context, builder: (_) => ConfirmDeleteDialog(
                  title: _note.title,
                  onDelete: () => Navigator.pop(context),
                ));
                
              }
              
            },
          )
        )
      ])
    ));
  }

}