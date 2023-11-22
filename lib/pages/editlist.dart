import 'package:flutter/material.dart';
import 'package:linknotes/database.dart';
import 'package:linknotes/pages/folders.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/widgets/menu.dart';
import 'package:linknotes/widgets/nobackgroundtextfield.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/confirmdeletedialog.dart';
import 'package:linknotes/widgets/changetitledialog.dart';

class EditListPage extends StatefulWidget {

  final ListNote note;

  const EditListPage({super.key, required this.note});

  @override
  State<EditListPage> createState() => _EditListState();

}

class _EditListState extends State<EditListPage> {

  late ListNote _note;
  var _focusNodes = <FocusNode>[];
  var _controllers = <TextEditingController>[];
  bool? _addedToFolder;
  var _folders = <Folder>[];
  final _menuOpen = ValueNotifier(false);

  final _focused = <bool>[];

  @override
  void initState() {
    super.initState();
    _note = widget.note.clone();
    for (final _ in _note.items) {
      _focused.add(false);
    }
    (() async {
      _folders = await getFolders();
      setState(() {
        _addedToFolder = _folders.where((f) => f.noteIds.contains(_note.id)).isNotEmpty;
      });
    })();
    updateItems();
  }

  @override
  void dispose() {
    for (var i = 0; i < _focusNodes.length; i++) {
      _controllers[i].dispose();
      _focusNodes[i].dispose();
    }
    _menuOpen.dispose();
    super.dispose();
  }

  void updateItems() {
    _focusNodes = [];
    _controllers = [];
    for (var i = 0; i < _note.items.length; i++) {
      final node = FocusNode();
      node.addListener(() {
        setState(() => _focused[i] = node.hasFocus);
      });
      final controller = TextEditingController(text: _note.items[i]);
      controller.addListener(() {
        _note.items[i] = controller.text;
      });
      _controllers.add(controller);
      _focusNodes.add(node);
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
            onPressed: () {
              _menuOpen.value = !_menuOpen.value;
              setState(() {});
            },
            icon: Icon(_menuOpen.value ? Icons.close : Icons.more_vert, color: Theme.of(context).primaryColor)
          ),
          const SizedBox(width: 10.0)
        ],
      ),
      body: Stack(
        children: [ContentContainer(
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
              shadowColor: Colors.transparent
            ),
            child: ReorderableListView(
              header: const SizedBox(height: 20.0),
              onReorderStart: (index) => setState(() {
                for (var i = 0; i < _focusNodes.length; i++) {
                  _focused[i] = false;
                  _focusNodes[i].unfocus();
                }
              }),
              onReorder: (oldIndex, newIndex) => setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = _note.items.removeAt(oldIndex);
                final itemIsSublist = _note.isSublist.removeAt(oldIndex);
                final itemIsChecked = _note.checked.removeAt(oldIndex);

                _note.items.insert(newIndex, item);
                _note.isSublist.insert(newIndex, itemIsSublist);
                _note.checked.insert(newIndex, itemIsChecked);
                
                updateItems();
              }),
              children: (() {
                var widgets = <Widget>[];
                for (var i = 0; i < _note.items.length; i++) {
                  widgets.add(Column(key: Key('$i'), children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _note.isSublist[i] ? const SizedBox(width: 20.0) : const SizedBox(width: 0.0),
                        Checkbox(value: _note.checked[i], onChanged: (value) => setState(() {
                          _note.checked[i] = value!;
                        })),
                        Expanded(child: NoBackgroundTextField(
                          controller: _controllers[i],
                          placeholder: 'type here',
                          focusNode: _focusNodes[i],
                        )),
                        _focused[i] ? TextButton(
                          onPressed: () => setState(() {
                            if (_note.items.length == 1) {
                              return;
                            }
                            _note.items.removeAt(i);
                            _focused.removeAt(i);
                            _note.isSublist.removeAt(i);
                            _note.checked.removeAt(i);

                            updateItems();
                          }),
                          child: Icon(Icons.close, color: Theme.of(context).hintColor),
                        ) : Container(),
                        _focused[i] ? ReorderableDragStartListener(
                          key: Key('$i'),
                          index: i,
                          child: Icon(Icons.drag_indicator, color: Theme.of(context).hintColor)
                        ) : Container(),
                      ]
                    ),
                    _focused[i] ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _note.items.insert(i + 1, '');
                            _note.isSublist.insert(i + 1, false);
                            _note.checked.add(false);
                            _focused.add(false);
                            _focusNodes[i].unfocus();
                            updateItems();
                            _focusNodes[i + 1].requestFocus();
                          }),
                          icon: Icon(Icons.add, color: Theme.of(context).hintColor),
                          label: Text('item', style: Theme.of(context).textTheme.labelSmall!)
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _note.items.insert(i + 1, '');
                            _note.isSublist.insert(i + 1, true);
                            _note.checked.add(false);
                            _focused.add(false);
                            _focusNodes[i].unfocus();
                            updateItems();
                            _focusNodes[i + 1].requestFocus();
                          }),
                          icon: Icon(Icons.add, color: Theme.of(context).hintColor),
                          label: Text('subitem', style: Theme.of(context).textTheme.labelSmall!)
                        )
                      ]
                    ) : Container() 
                  ]));
                }
                return widgets;
              })()
            )
          ),
        ),
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
              'Disable checkboxes',
              'Delete note'
            ],
            icons: [
              Icon(Icons.link, color: Theme.of(context).primaryColor),
              Icon(Icons.title, color: Theme.of(context).primaryColor),
              Icon(Icons.dashboard, color: Theme.of(context).primaryColor), 
              Icon(Icons.folder, color: Theme.of(context).primaryColor),
              Icon(Icons.check_box, color: Theme.of(context).primaryColor),
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
                  getFolder: () async {
                    return await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const FoldersPage(selectingFolder: true),
                      fullscreenDialog: true
                    ));
                });
                setState(() {
                  _addedToFolder = !_addedToFolder!;
                });
                saveFolders(folders: _folders);
              } else if (index == 5) {
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
        )]
      )
    ));
  }

}