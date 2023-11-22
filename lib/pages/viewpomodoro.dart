import 'package:flutter/material.dart';
import 'package:linknotes/pages/editpomodoro.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/timer.dart';

class ViewPomodoroPage extends StatefulWidget {

  final PomodoroNote note;

  const ViewPomodoroPage({super.key, required this.note});

  @override
  State<ViewPomodoroPage> createState() => _ViewPomodoroState();

}

class _ViewPomodoroState extends State<ViewPomodoroPage> {

  late PomodoroNote _note;
  late ValueNotifier<String> _name;
  late ValueNotifier<int> _duration;


  @override
  void initState() {
    super.initState();
    _note = widget.note.clone();
    _name = ValueNotifier(_note.currentName);
    _duration = ValueNotifier(_note.currentDuration);
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context, _note)),
        title: Center(child: Text(_note.title, style: Theme.of(context).textTheme.displayMedium!)),
        actions: [
          IconButton(
            onPressed: () async {
              final newNote = await Navigator.push(context, MaterialPageRoute(
                builder: (_) => EditPomodoroPage(note: _note),
                fullscreenDialog: true
              ));
              if (!mounted) return;
              if (newNote == null) {
                (() {
                  Navigator.pop(context);
                })();
                return;
              }
              _note = newNote;
              setState(() {
                _note.reset();
              });
              _name.value = _note.currentName;
              _duration.value = _note.currentDuration;
            },
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 10.0)
        ]
      ),
      body: ContentContainer(
        child: Column(children: [
          const SizedBox(height: 50.0),
          TimerWidget(
            name: _name,
            duration: _duration,
            onNextTimer: () {
              _note.next();
              _name.value = _note.currentName;
              _duration.value = _note.currentDuration;
            }
          ),
          const SizedBox(height: 50.0),
          Center(child: SizedBox(
            width: 200.0,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _note.nextTask();
                });
                _name.value = _note.currentName;
                _duration.value = _note.currentDuration;
              },
              child: Text('Finish', style: Theme.of(context).textTheme.displaySmall!)
            ),
          ))
        ]),
      )
    ));
  }

}