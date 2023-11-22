import 'package:flutter/material.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/pages/edittimers.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/timer.dart';

class ViewTimersPage extends StatefulWidget {

  final TimersNote note;

  const ViewTimersPage({super.key, required this.note});

  @override
  State<ViewTimersPage> createState() => _ViewTimersState();

}


class _ViewTimersState extends State<ViewTimersPage> {

  late TimersNote _note;
  late ValueNotifier<String> _name;
  late ValueNotifier<int> _duration;

  @override
  void initState() {
    super.initState();
    _note = widget.note.clone();
    _name = ValueNotifier(_note.currentTimer?.name ?? 'no timer');
    _duration = ValueNotifier(_note.currentTimer?.duration ?? 0);
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
                builder: (_) => EditTimersPage(note: _note),
                fullscreenDialog: true
              ));
              if (newNote == null) {
                (() {
                  Navigator.pop(context);
                })();
                return;
              }
              setState(() {
                _note = newNote;
                _note.currentTimer?.reset();
              });
              _name.value = _note.currentTimer?.name ?? 'no timer';
              _duration.value = _note.currentTimer?.duration ?? 0;
            },
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor)
          ),
          const SizedBox(width: 10.0)
        ]
      ),
      body: ContentContainer(child: Column(
        children: [
          const SizedBox(height: 100.0),
          TimerWidget(
            name: _name,
            duration: _duration,
            onNextTimer: () {
              _note.nextTimer();
              _name.value = _note.currentTimer?.name ?? 'no timer';
              _duration.value = _note.currentTimer?.duration ?? 0;
            }
          )
        ]
      ))
    ));
  }
}