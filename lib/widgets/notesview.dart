import 'package:flutter/material.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';
import 'package:linknotes/pages/edittasks.dart';
import 'package:linknotes/widgets/undodelete.dart';
import 'package:linknotes/pages/editalarms.dart';
import 'package:linknotes/pages/editcalendar.dart';
import 'package:linknotes/pages/editincrementer.dart';
import 'package:linknotes/pages/editlist.dart';
import 'package:linknotes/pages/edittext.dart';
import 'package:linknotes/pages/viewtimers.dart';
import 'package:linknotes/pages/viewpomodoro.dart';

typedef NoteCallback = void Function(Note note);
typedef FilterCallback = bool Function(Note note);

class NoteView extends StatelessWidget {

  final Note note;
  final NoteCallback onPressed;

  const NoteView({
    super.key,
    required this.note,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onPressed(note),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const SizedBox(width: 5.0),
              Flexible(child: Text(note.title, style: Theme.of(context).textTheme.displayMedium!)),
            ]),
            const SizedBox(height: 20.0),
            (() {
              if (note is TextNote) {
                return Row(children: [
                  const SizedBox(width: 5.0),
                  Flexible(child: Text((note as TextNote).text, style: Theme.of(context).textTheme.displaySmall!, overflow: TextOverflow.visible,))
                ]);
              } else if (note is ListNote) {
                final listNote = note as ListNote;
                return Column(children: (() {
                  var widgets = <Widget>[];
                  for (var i = 0; i < listNote.items.length; i++) {
                    widgets.add(Row(children: [
                      SizedBox(width: listNote.isSublist[i] ? 20.0 : 10.0),
                      SizedBox.square(
                        dimension: 10.0,
                        child: Checkbox(
                          onChanged: null,
                          value: listNote.checked[i],
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Flexible(child: Text(listNote.items[i], style: Theme.of(context).textTheme.displaySmall!))
                    ]));
                    widgets.add(const SizedBox(height: 10.0));
                  }
                  return widgets;
                })());
              } else if (note is TimersNote) {
                final timerNote = note as TimersNote;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(timerNote.currentTimer?.name ?? 'no timers', style: Theme.of(context).textTheme.displaySmall!),
                    const SizedBox(height: 5.0),
                    Text(timerNote.currentTimer?.minutesAndSeconds ?? '', style: Theme.of(context).textTheme.displaySmall!),
                    const SizedBox(height: 20.0),
                    Center(child: SizedBox(
                      width: 100.0,
                      child: ElevatedButton(
                        onPressed: null,
                        child: Text('Start', style: Theme.of(context).textTheme.displaySmall!)
                      )
                    )),
                    const SizedBox(height: 20.0)
                  ]
                );
              } else if (note is AlarmsNote) {
                final alarmsNote = note as AlarmsNote;
                return Column(
                  children: (() {
                    var items = <Widget>[];
                    for (final alarm in alarmsNote.alarms) {
                      items.add(Column(children: [
                        Row(children: [
                          const SizedBox(width: 5.0),
                          Flexible(child: Text(alarm.name, style: Theme.of(context).textTheme.displaySmall!))
                        ]),
                        const SizedBox(height: 5.0),
                        Row(children: [
                          const SizedBox(width: 5.0),
                          Text(alarm.time, style: Theme.of(context).textTheme.displaySmall!)
                        ]),
                        const SizedBox(height: 10.0)
                      ]));
                    }
                    return items;
                  })(),
                );
              } else if (note is IncrementerNote) {
                final incrementerNote = note as IncrementerNote;
                return Column(children: [
                  Center(child: Text('-   ${incrementerNote.value}   +', style: Theme.of(context).textTheme.displaySmall!)),
                  const SizedBox(height: 10.0)
                ]);
              } else if (note is CalendarNote) {
                return Column(children: [
                  GridView.count(
                    crossAxisCount: 7,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: List.generate(30, (index) => Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(70, 70, 100, 1),
                        borderRadius: BorderRadius.circular(1000000.0)
                      ), 
                    )),
                  ),
                  const SizedBox(height: 10.0)
                ]);
              } else if (note is TasksNote) {
                final tasksNote = note as TasksNote;
                return Column(children: (() {
                  var items = <Widget>[];
                  for (final task in tasksNote.tasks) {
                    if (task.isCompleted) {
                      break;
                    }
                    items.add(Row(
                      children: [
                        const SizedBox(width: 10.0),
                        const SizedBox.square(
                          dimension: 10.0,
                          child: Checkbox(
                            onChanged: null,
                            value: false,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Flexible(child: Text(task.name, style: Theme.of(context).textTheme.displaySmall!))
                      ]
                    ));
                    items.add(const SizedBox(height: 10.0));
                  }
                  return items;
                })());
              } else if (note is PomodoroNote) {
                final pomodoroNote = note as PomodoroNote;
                return Column(children: (() {
                  var items = <Widget>[];
                  for (final task in pomodoroNote.tasks) {
                    items.add(Row(children: [
                      const SizedBox(width: 10.0),
                      const SizedBox.square(
                        dimension: 10.0,
                        child: Checkbox(
                          onChanged: null,
                          value: false,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Flexible(child: Text(task, style: Theme.of(context).textTheme.displaySmall!))
                    ]));
                    items.add(const SizedBox(height: 10.0));
                  }
                  return items;
                })());
              }
              return Container();
            })()
          ]
        ))])
      )
    );
  }

}

class NotesView extends StatefulWidget {

  final List<Note> notes;
  final NoteCallback? onNotePressed;
  final FilterCallback? filter;
  final NoteCallback? onNoteUpdated;
  final NoteCallback? onNoteDeleted;

  const NotesView({
    super.key,
    required this.notes,
    this.onNotePressed,
    this.filter,
    this.onNoteUpdated,
    this.onNoteDeleted
  });

  @override
  State<NotesView> createState() => _NotesViewState();

}

class _NotesViewState extends State<NotesView> {

  var _column1Notes = <Note>[];
  var _column2Notes = <Note>[];

  late NoteCallback _onNotePressed;

  void _updateColumns() {
    _column1Notes = [];
    _column2Notes = [];
    bool column1 = true;

    for (final note in widget.notes) {
      if (widget.filter != null && !widget.filter!(note)) {
        continue;
      }
      if (column1) {
        _column1Notes.add(note);
      } else {
        _column2Notes.add(note);
      }
      column1 = !column1;
    }

    _onNotePressed = widget.onNotePressed ?? (note) async {
      late MaterialPageRoute route;
      if (note is TextNote) {
        route = MaterialPageRoute(
          builder: (_) => EditTextPage(note: note),
          fullscreenDialog: true
        );
        
      } else if (note is ListNote) {
        route = MaterialPageRoute(
          builder: (_) => EditListPage(note: note),
          fullscreenDialog: true
        );
      } else if (note is TimersNote) {
        route = MaterialPageRoute(
          builder: (_) => ViewTimersPage(note: note),
          fullscreenDialog: true
        );
      } else if (note is AlarmsNote) {
        route = MaterialPageRoute(
          builder: (_) => EditAlarmsPage(note: note),
          fullscreenDialog: true
        );
      } else if (note is IncrementerNote) {
        route = MaterialPageRoute(
          builder: (_) => EditIncrementerPage(note: note),
          fullscreenDialog: true
        );
      } else if (note is CalendarNote) {
        route = MaterialPageRoute(
          builder: (_) => EditCalendarPage(note: note),
          fullscreenDialog: true
        );
      } else if (note is TasksNote) {
        route = MaterialPageRoute(
          builder: (_) => EditTasksPage(note: note),
          fullscreenDialog: true
        );
      } else if (note is PomodoroNote) {
        route = MaterialPageRoute(
          builder: (_) => ViewPomodoroPage(note: note),
          fullscreenDialog: true
        );
      }
      final newNote = await Navigator.push(context, route);
      if (!mounted) return;

      for (var i = 0; i < widget.notes.length; i++) {
        if (widget.notes[i].id == note.id) {
          if (newNote == null) {
            final deletedNote = widget.notes[i];
            final deletedIndex = i;
            showUndoDelete(
              context: context, 
              title: deletedNote.title,
              onUndoDelete: () {
                setState(() {
                  widget.notes.insert(deletedIndex, deletedNote);  
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                saveNotes(notes: widget.notes);
              }
            );
          }
          setState(() {
            if (newNote == null) {
              (widget.onNoteDeleted ?? ((_) {}))(widget.notes[i]);
              widget.notes.removeAt(i);
            } else {
              (widget.onNoteUpdated ?? ((_) {}))(newNote);
              widget.notes[i] = newNote;
            }
          });
          saveNotes(notes: widget.notes);
          break;
        }
      }
    };
  }

  @override
  void initState() {
    super.initState();
    _updateColumns();
  }

  @override
  Widget build(BuildContext context) {
    _updateColumns();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _column1Notes.isEmpty ? [
        Text('nothin\' here :/', style: Theme.of(context).textTheme.labelSmall!)
      ] : [
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: (() {
          var items = <Widget>[];
          for (final note in _column1Notes) {
            items.add(NoteView(note: note, onPressed: _onNotePressed));
            items.add(const SizedBox(height: 10.0));
          }
          return items;
        })())),
        const SizedBox(width: 10.0),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: (() {
          var items = <Widget>[];
          for (final note in _column2Notes) {
            items.add(NoteView(note: note, onPressed: _onNotePressed));
            items.add(const SizedBox(height: 10.0));
          }
          return items;
        })()))
      ],
    );
  }
}