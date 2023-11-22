import 'package:flutter/material.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';
import 'package:linknotes/pages/edittask.dart';
import 'package:linknotes/pages/folders.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/changetitledialog.dart';
import 'package:linknotes/widgets/confirmdeletedialog.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/undodelete.dart';
import 'package:linknotes/widgets/menu.dart';

class EditTasksPage extends StatefulWidget {

  final TasksNote note;

  const EditTasksPage({super.key, required this.note});

  @override
  State<EditTasksPage> createState() => _EditTasksState();

}

class _EditTasksState extends State<EditTasksPage> {

  final _menuOpen = ValueNotifier(false);
  late TasksNote _note;
  var _changingTaskLocations = false;
  bool? _addedToFolder;
  var _folders = <Folder>[];
  late List<bool> _checkStates;

  @override
  void initState() {
    super.initState();
    _note = widget.note.clone();
    _updateTasks();
    _updateCheckStates();
    (() async {
      _folders = await getFolders();
      setState(() {
        _addedToFolder = _folders.where((f) => f.noteIds.contains(_note.id)).isNotEmpty;
      });
    })();
  }

  void _updateTasks() {
    var completedTasks = <Task>[];
    var tasksWithDueDates = <Task>[];
    var tasksWithoutDueDates = <Task>[];
    
    for (var i = 0; i < _note.tasks.length; i++) {
      if (_note.tasks[i].isCompleted) {
        completedTasks.insert(0, _note.tasks[i]);
      } else if (_note.tasks[i].dueDate == null) {
        tasksWithoutDueDates.add(_note.tasks[i]);
      } else {
        tasksWithDueDates.add(_note.tasks[i]);
      }
    }

    tasksWithDueDates.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    _note.tasks = [...tasksWithDueDates, ...tasksWithoutDueDates, ...completedTasks];
    
  }

  void _updateCheckStates() {
    _checkStates = _note.tasks.map((task) => task.isCompleted).toList();
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
          const SizedBox(width: 10.0,)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => EditTaskPage(task: Task(name: '', repeatFrequency: RepeatFrequency.doesnotrepeat), creatingTask: true),
            fullscreenDialog: true
          ));
          if (!mounted || newTask == null) return;

          setState(() {
            _note.tasks.add(newTask);
            _updateTasks();
            _updateCheckStates();
          });
          
        },
        child: Icon(Icons.add, color: Theme.of(context).primaryColor,)
      ),
      body: Stack(
        children: [
          ContentContainer(child: ListView(
            children: (() {
              var items = <Widget>[];
              var completedStartIndex = -1;

              for (var i = _note.tasks.length - 1; i >= 0; i--) {
                if (!_note.tasks[i].isCompleted) {
                  break;
                }
                completedStartIndex = i;
              }

              items.add(const SizedBox(height: 20.0));
              for (var i = 0; i < _note.tasks.length; i++) {
                if (i == completedStartIndex) {
                  items.add(const SizedBox(height: 20.0));
                  items.add(const Divider(indent: 10.0, endIndent: 10.0,));
                  items.add(const SizedBox(height: 20.0));
                }
                items.add(ListTile(
                  leading: Checkbox(
                    value: _checkStates[i],
                    onChanged: (value) async {
                      if (_changingTaskLocations) {
                        return;
                      }
                      setState(() {
                        _checkStates[i] = value!;
                      });
                      _changingTaskLocations = true;
                      await Future.delayed(const Duration(milliseconds: 500));
                      _changingTaskLocations = false;
                      setState(() {
                        _note.tasks[i].isCompleted = value!;
                        if (value) {
                          final task = _note.tasks.removeAt(i);
                          if (completedStartIndex < 0) {
                            _note.tasks.add(task);
                          } else {
                            _note.tasks.insert(completedStartIndex - 1, task);
                          }
                        } else {
                          _updateTasks();
                        }
                        _updateCheckStates();
                      });
                      
                    },
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      final newTask = await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => EditTaskPage(task: _note.tasks[i], creatingTask: false),
                        fullscreenDialog: true
                      ));
                      if (!mounted) return;
                      
                      if (newTask == null) {
                        final deletedTask = _note.tasks[i];
                        final deletedIndex = i;
                        setState(() {
                          _note.tasks.removeAt(i);
                          _updateTasks();
                          _updateCheckStates();
                        });
                        showUndoDelete(
                          context: context,
                          title: deletedTask.name,
                          onUndoDelete: () {
                            setState(() {
                              _note.tasks.insert(deletedIndex, deletedTask);
                              _updateTasks();
                              _updateCheckStates();
                            });
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          }
                        );
                      } else {
                        setState(() {
                          _note.tasks[i] = newTask;
                          _updateTasks();
                          _updateCheckStates();
                        });
                      }
                    },
                    child: Icon(Icons.edit, color: Theme.of(context).hintColor)
                  ),
                  title: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    Text(_note.tasks[i].name, style: Theme.of(context).textTheme.displayMedium!),
                    _note.tasks[i].details == null 
                    ? Container() : Text(_note.tasks[i].details!, style: Theme.of(context).textTheme.displaySmall!, overflow: TextOverflow.visible,),
                    _note.tasks[i].dueDate == null ? 
                    Container() : Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text((() {
                        final dueDate = _note.tasks[i].dueDate!;
                        return '${dueDate.month}/${dueDate.day}/${dueDate.year}';
                      })(), style: Theme.of(context).textTheme.displaySmall!)
                    )
                  ])
                ));
                items.add(const SizedBox(height: 10.0));
              }
              
              return items;
            })(),
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
                'Delete completed tasks',
                'Delete note'
              ],
              icons: [
                Icon(Icons.link, color: Theme.of(context).primaryColor),
                Icon(Icons.title, color: Theme.of(context).primaryColor),
                Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
                Icon(Icons.folder, color: Theme.of(context).primaryColor),
                Icon(Icons.delete, color: Theme.of(context).primaryColor),
                Icon(Icons.delete, color: Theme.of(context).primaryColor)
              ],
              onSelected: (index) async {
                if (index == 1) {
                  showDialog(context: context, builder: (_) => ChangeTitleDialog(
                    onTitleChanged: (value) => setState(() {
                      _note.title = value;
                    }),
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
                  setState(() {
                    _note.tasks.removeWhere((task) => task.isCompleted);
                  });
                } else if (index == 5) {
                  showDialog(context: context, builder: (_) => ConfirmDeleteDialog(
                    onDelete: () {
                      Navigator.pop(context);
                    },
                    title: _note.title
                  ));
                }
              },
            ),
          )
        ],
      ),
    ));
  }

}