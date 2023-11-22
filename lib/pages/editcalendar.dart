import 'package:flutter/material.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';
import 'package:linknotes/pages/folders.dart';
import 'package:linknotes/widgets/menu.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/changetitledialog.dart';
import 'package:linknotes/widgets/confirmdeletedialog.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/pages/editevent.dart';
import 'package:linknotes/widgets/undodelete.dart';

class EditCalendarPage extends StatefulWidget {

  final CalendarNote note;

  const EditCalendarPage({super.key, required this.note});

  @override
  State<EditCalendarPage> createState() => _EditCalendarState();

}

class _EditCalendarState extends State<EditCalendarPage> {
  
  late CalendarNote _note;
  var _month = DateTime.now();
  int? _selectedIndex;
  bool? _addedToFolder;
  var _folders = <Folder>[];
  final _menuOpen = ValueNotifier(false);

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

  int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
  int getStartDay(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday;
  }
  String getMonth(DateTime date) {
    return ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'][date.month - 1];
  }
  List<Event> getEvents(int index) => _note.events.where(
    (event) {
      final day = index + 2 - getStartDay(_month);
      if (event.repeatFrequency == RepeatFrequency.weekly) {
        return event.time.weekday == DateTime(_month.year, _month.month, day).weekday;
      } else if (event.repeatFrequency == RepeatFrequency.monthly) {
        return event.time.day == day;
      } else if (event.repeatFrequency == RepeatFrequency.yearly) {
        return day == event.time.day && _month.month == event.time.month;
      }
      return day == event.time.day && _month.month == event.time.month && _month.year == event.time.year;
    }
  ).toList();

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
          if (_selectedIndex == null) {
            return;
          }
          final newEvent = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => EditEventPage(event: Event(
              name: '',
              duration: Duration.zero,
              allDay: false,
              repeatFrequency: RepeatFrequency.doesnotrepeat,
              time: DateTime(_month.year, _month.month, _selectedIndex! + 2 - getStartDay(_month))
            ), creatingEvent: true),
            fullscreenDialog: true
          ));
          if (!mounted || newEvent == null) return;

          setState(() {
            _note.events.add(newEvent);  
          });
        },
        child: const Icon(Icons.add,
          size: 30.0, 
          color: Color.fromRGBO(180, 180, 190, 1)
        )
      ),
      body: Stack(children: [
        ContentContainer(child: Column(
          children: [
            const SizedBox(height: 20.0),
            ListTile(
              leading: IconButton(
                onPressed: () => setState(() {
                  _month = DateTime(_month.year, _month.month - 1);
                }),
                icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor)
              ),
              title: Center(child: Text('${getMonth(_month)} ${_month.year}', style: Theme.of(context).textTheme.displaySmall!)),
              trailing: Row(mainAxisSize: MainAxisSize.min ,children: [
                IconButton(
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month + 1);
                  }),
                  icon: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor)
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _month = DateTime.now();
                    _selectedIndex = _month.day - 2 + getStartDay(_month);
                  }),
                  icon: Icon(Icons.today, color: Theme.of(context).primaryColor)
                )
              ])
            ),
            const SizedBox(height: 10.0),
            GridView.count(
              crossAxisCount: 7,
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [...['M', 'T', 'W', 'T', 'F', 'S', 'S'].map(
                  (day) => Center(child: Text(day, style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    decoration: TextDecoration.underline,
                  )))
                ), ...List.generate(getDaysInMonth(_month) + getStartDay(_month) - 1, (index) => TextButton(
                onPressed: () {
                  if (index < getStartDay(_month) - 1) {
                    return;
                  }
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: getEvents(index).isNotEmpty ? const Color.fromRGBO(70, 70, 100, 1) : Colors.transparent, width: 2.0),
                    borderRadius: BorderRadius.circular(1000.0)
                  ),  
                  backgroundColor: _selectedIndex == index ? const Color.fromRGBO(70, 70, 100, 1) : null
                ),
                child: Center(child: Text((() {
                  final day = index + 2 - getStartDay(_month);
                  return day <= 0 ? '' : '$day';
                })(), style: Theme.of(context).textTheme.displaySmall!))
              ))],
            ),
            const SizedBox(height: 10.0),
            Expanded(child: ListView(children: [...getEvents(_selectedIndex ?? -9999).map(
              (event) => ListTile(
                title: Text(event.name, style: Theme.of(context).textTheme.displaySmall!),
                trailing: TextButton(
                  onPressed: () async {
                    final newEvent = await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => EditEventPage(event: event, creatingEvent: false),
                      fullscreenDialog: true
                    ));
                    if (!mounted) return;
                    
                    for (var i = 0; i < _note.events.length; i++) {
                      if (_note.events[i].id == event.id) {
                        if (newEvent == null) {
                          final deletedEvent = _note.events[i];
                          final deletedIndex = i;
                          showUndoDelete(
                            context: context,
                            title: deletedEvent.name,
                            onUndoDelete: () {
                              setState(() {
                                _note.events.insert(deletedIndex, deletedEvent);
                              });
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            }
                          );
                          setState(() {
                            _note.events.removeAt(i);  
                          });
                        } else {
                          setState(() {
                            _note.events[i] = newEvent;
                          });
                        }
                        break;
                      }
                    }
                  },
                  child: Icon(Icons.edit, color: Theme.of(context).hintColor)
                )
              )
            ).toList(), const SizedBox(height: 50.0)])),
            
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
          ),
        )
      ])
    ));
  }
}