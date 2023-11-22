import 'package:flutter/material.dart';
import 'package:linknotes/pages/folders.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/menu.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/changetitledialog.dart';
import 'package:linknotes/widgets/confirmdeletedialog.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';

class EditTimersPage extends StatefulWidget {

  final TimersNote note;

  const EditTimersPage({super.key, required this.note});

  @override
  State<EditTimersPage> createState() => _EditTimersState();

}

class _EditTimersState extends State<EditTimersPage> {

  final _menuOpen = ValueNotifier(false);
  late TimersNote _note;
  late List<TextEditingController> _nameControllers;
  late List<TextEditingController> _durationControllers;
  late List<FocusNode> _nameFocusNodes;
  late List<FocusNode> _durationFocusNodes;
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
    for (var i = 0; i < _note.timers.length; i++) {
      _nameControllers[i].dispose();
      _durationControllers[i].dispose();
      _nameFocusNodes[i].dispose();
      _durationFocusNodes[i].dispose();
    }
    super.dispose();
  }

  void _updateTextFields() {
    _nameControllers = [];
    _durationControllers = [];
    _nameFocusNodes = [];
    _durationFocusNodes = [];
    for (var i = 0; i < _note.timers.length; i++) {
      final nameController = TextEditingController(text: _note.timers[i].name);
      nameController.addListener(() {
        _note.timers[i].name = nameController.text;
      });
      _nameControllers.add(nameController);

      final durationController = TextEditingController(text: '${(_note.timers[i].duration / 60).round()}');
      durationController.addListener(() {
        _note.timers[i].duration = (int.tryParse(durationController.text) ?? 0) * 60;
      });
      _durationControllers.add(durationController);

      final nameFocusNode = FocusNode();
      _nameFocusNodes.add(nameFocusNode);

      final durationFocusNode = FocusNode();
      _durationFocusNodes.add(durationFocusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context, _note)),
        title: Center(child: Text('Edit', style: Theme.of(context).textTheme.displayMedium!)),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _menuOpen.value = !_menuOpen.value;
              });
            },
            icon: Icon(_menuOpen.value ? Icons.close : Icons.more_vert, color: Theme.of(context).primaryColor)
          ),
          const SizedBox(width: 10.0)
        ],
      ),
      body: Stack(
        children: [
          ContentContainer(child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
              shadowColor: Colors.transparent
            ),
            child: ReorderableListView(
              onReorderStart: (index) => setState(() {
                for (var i = 0; i < _nameFocusNodes.length; i++) {
                  _nameFocusNodes[i].unfocus();
                  _durationFocusNodes[i].unfocus();
                }
              }),
              onReorder: ((oldIndex, newIndex) => setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final timer = _note.timers.removeAt(oldIndex);
                _note.timers.insert(newIndex, timer);
                _updateTextFields();
                
              })),
              header: const SizedBox(height: 20.0),
              footer: Column(children: [
                const SizedBox(height: 20.0),
                Center(child: SizedBox(
                  width: 200.0,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() {
                      for (var i = 0; i < _nameFocusNodes.length; i++) {
                        _nameFocusNodes[i].unfocus();
                        _durationFocusNodes[i].unfocus();
                      }
                      _note.timers.add(Timer(name: '', duration: 0));
                      _updateTextFields();
                      
                    }),
                    icon: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 30.0),
                    label: Text('Add', style: Theme.of(context).textTheme.displaySmall!)
                  )
                ))
              ]),
              children: (() {
                var items = <Widget>[];
                
                for (var i = 0; i < _note.timers.length; i++) {
                  items.add(Padding(
                    key: Key('$i'),
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(child: TextField(
                          focusNode: _nameFocusNodes[i],
                          controller: _nameControllers[i],
                          style: Theme.of(context).textTheme.displaySmall!,
                          decoration: const InputDecoration(
                            hintText: 'name'
                          ),
                        )),
                        const SizedBox(width: 5.0),
                        SizedBox(width: 100.0, child: TextField(
                          focusNode: _durationFocusNodes[i],
                          controller: _durationControllers[i],
                          style: Theme.of(context).textTheme.displaySmall!,
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            suffixText: 'm'
                          )
                        )),
                        TextButton(
                          onPressed: () => setState(() {
                            for (var i = 0; i < _nameFocusNodes.length; i++) {
                              _nameFocusNodes[i].unfocus();
                              _durationFocusNodes[i].unfocus();
                            }
                            _note.timers.removeAt(i);
                            _updateTextFields();
                            
                          }), 
                          child: Icon(Icons.close, color: Theme.of(context).hintColor)
                        ),
                        ReorderableDragStartListener(
                          key: Key('$i'),
                          index: i,
                          child: Icon(Icons.drag_indicator, color: Theme.of(context).hintColor),
                        )
                      ],
                    )
                  ));
                }
                return items;
              })(),
            
            )
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