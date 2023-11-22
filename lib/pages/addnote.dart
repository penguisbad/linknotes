import 'package:flutter/material.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/model.dart';

class AddNotePage extends StatefulWidget {

  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNoteState();

}

enum NoteType { text, list, timers, alarms, incrementer, calendar, tasks, pomodoro }

class _AddNoteState extends State<AddNotePage> {

  var _noteType = NoteType.text;
  var _title = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context)),
        title: Text('Add note', style: Theme.of(context).textTheme.displayMedium!),
      ),
      body: ContentContainer(maxWidth: 300.0, child: ListView(
        children: [
          const SizedBox(height: 50.0),
          TextField(
            onChanged: (value) => _title = value,
            style: Theme.of(context).textTheme.displaySmall!,
            decoration: const InputDecoration(
              hintText: 'title'
            ),
          ),
          const SizedBox(height: 20.0),
          ListTile(
            title: Text('Text', style: Theme.of(context).textTheme.displaySmall!),
            leading: Radio<NoteType>(
              value: NoteType.text,
              groupValue: _noteType,
              onChanged: (value) => setState(() => _noteType = value!),
            )
          ),
          ListTile(
            title: Text('List', style: Theme.of(context).textTheme.displaySmall!),
            leading: Radio<NoteType>(
              value: NoteType.list,
              groupValue: _noteType,
              onChanged: (value) => setState(() => _noteType = value!),
            )
          ),
          ListTile(
            title: Text('Timers', style: Theme.of(context).textTheme.displaySmall!),
            leading: Radio<NoteType>(
              value: NoteType.timers,
              groupValue: _noteType,
              onChanged: (value) => setState(() => _noteType = value!),
            )
          ),
          ListTile(
            title: Text('Alarms', style: Theme.of(context).textTheme.displaySmall!),
            leading: Radio<NoteType>(
              value: NoteType.alarms,
              groupValue: _noteType,
              onChanged: (value) => setState(() => _noteType = value!),
            )
          ),
          ListTile(
            title: Text('Incrementer', style: Theme.of(context).textTheme.displaySmall!),
            leading: Radio<NoteType>(
              value: NoteType.incrementer,
              groupValue: _noteType,
              onChanged: (value) => setState(() => _noteType = value!),
            )
          ),
          ListTile(
            title: Text('Calendar', style: Theme.of(context).textTheme.displaySmall!),
            leading: Radio<NoteType>(
              value: NoteType.calendar,
              groupValue: _noteType,
              onChanged: (value) => setState(() => _noteType = value!),
            )
          ),
          ListTile(
            title: Text('Task list', style: Theme.of(context).textTheme.displaySmall!),
            leading: Radio<NoteType>(
              value: NoteType.tasks,
              groupValue: _noteType,
              onChanged: (value) => setState(() => _noteType = value!),
            )
          ),
          ListTile(
            title: Text('Pomodoro Timer', style: Theme.of(context).textTheme.displaySmall!),
            leading: Radio<NoteType>(
              value: NoteType.pomodoro,
              groupValue: _noteType,
              onChanged: (value) => setState(() => _noteType = value!),
            ),
          ),
          const SizedBox(height: 50.0),
          Center(child: SizedBox(
            width: 200.0,
            child: ElevatedButton(
              onPressed: () {
                late Note newNote;
                switch (_noteType) {
                  case NoteType.text:
                    newNote = TextNote(title: _title, text: '');
                    break;
                  case NoteType.list:
                    newNote = ListNote(title: _title, items: [''], isSublist: [false]);
                    break;
                  case NoteType.timers:
                    newNote = TimersNote(title: _title, timers: []);
                    break;
                  case NoteType.alarms:
                    newNote = AlarmsNote(title: _title, alarms: []);
                    break;
                  case NoteType.incrementer:
                    newNote = IncrementerNote(title: _title, value: 0);
                    break;
                  case NoteType.calendar:
                    newNote = CalendarNote(title: _title, events: []);
                    break;
                  case NoteType.tasks:
                    newNote = TasksNote(title: _title, tasks: []);
                    break;
                  default:
                    return;
                }
                Navigator.pop(context, newNote);
              },
              child: Text('Add', style: Theme.of(context).textTheme.displaySmall!)
            )
          ))
        ],
      ))
    );
  }

}