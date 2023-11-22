import 'package:flutter/material.dart';
import 'package:linknotes/pages/editalarm.dart';
import 'package:linknotes/pages/folders.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/menu.dart';
import 'package:linknotes/widgets/changetitledialog.dart';
import 'package:linknotes/widgets/confirmdeletedialog.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';
import 'package:linknotes/widgets/undodelete.dart';

class EditAlarmsPage extends StatefulWidget {

  final AlarmsNote note;

  const EditAlarmsPage({super.key, required this.note});

  @override
  State<EditAlarmsPage> createState() => _EditAlarmsState();

}

class _EditAlarmsState extends State<EditAlarmsPage> {

  late AlarmsNote _note;
  final _menuOpen = ValueNotifier(false);
  bool? _addedToFolder;
  var _folders = <Folder>[];

  @override
  void initState() {
    super.initState();
    _note = widget.note.clone();
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
            onPressed: () => setState(() {
              _menuOpen.value = !_menuOpen.value;
            }),
            icon: Icon(_menuOpen.value ? Icons.close : Icons.more_vert, color: Theme.of(context).primaryColor)
          ),
          const SizedBox(width: 10.0)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAlarm = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => EditAlarmPage(
              alarm: Alarm(name: '', hour: 12, minute: 0, amOrPm: 'AM'),
              creatingAlarm: true,
            ),
            fullscreenDialog: true
          ));
          if (!mounted || newAlarm == null) return;
          setState(() {
            _note.alarms.add(newAlarm);
          });
        },
        child: const Icon(Icons.add,
          size: 30.0, 
          color: Color.fromRGBO(180, 180, 190, 1)
        )
      ),
      body: Stack(
        children: [
          ContentContainer(child: ListView.builder(
            itemCount: _note.alarms.length,
            itemBuilder: (context, index) => Padding(
              padding: index == 0 ? const EdgeInsets.only(top: 20.0, bottom: 10.0) : const EdgeInsets.only(bottom: 10.0),
              child: ListTile(
                trailing: TextButton(
                  onPressed: () async {
                    final newAlarm = await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => EditAlarmPage(alarm: _note.alarms[index]),
                      fullscreenDialog: true
                    ));
                    setState(() {
                      if (newAlarm == null) {
                        final deletedAlarm = _note.alarms[index];
                        final deletedIndex = index;
                        showUndoDelete(
                          context: context,
                          title: deletedAlarm.name,
                          onUndoDelete: () {
                            setState(() {
                              _note.alarms.insert(deletedIndex, deletedAlarm);
                            });
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          }
                        );
                        _note.alarms.removeAt(index);
                        return;
                      }
                      _note.alarms[index] = newAlarm;
                    });
                  },
                  child: Icon(Icons.edit, color: Theme.of(context).hintColor)
                ),
                title: IntrinsicHeight(child: Row(children: [
                  Flexible(child: Text(_note.alarms[index].name, style: Theme.of(context).textTheme.displayMedium!)),
                  const SizedBox(width: 10.0),
                  const VerticalDivider(thickness: 3.0, color: Color.fromRGBO(70, 70, 100, 1)),
                  const SizedBox(width: 10.0),
                  Text(_note.alarms[index].time, style: Theme.of(context).textTheme.displayMedium!),
                ]))
              )
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