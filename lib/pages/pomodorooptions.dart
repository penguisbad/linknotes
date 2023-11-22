import 'package:flutter/material.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/contentcontainer.dart';

class PomodoroOptionsPage extends StatefulWidget {

  final PomodoroNote note;

  const PomodoroOptionsPage({super.key, required this.note});

  @override
  State<PomodoroOptionsPage> createState() => _PomodoroOptionsState();

}

class _PomodoroOptionsState extends State<PomodoroOptionsPage> {

  late PomodoroNote _note;
  late TextEditingController _focusController;
  late TextEditingController _breakController;
  late TextEditingController _longBreakController;
  late TextEditingController _cyclesController;

  @override
  void initState() {
    super.initState();
    _note = widget.note.clone();
    
    _focusController = TextEditingController(text: '${_note.focusMinutes}')
    ..addListener(() {
      _note.focusMinutes = int.tryParse(_focusController.text) ?? 0;
    });
    
    _breakController = TextEditingController(text: '${_note.breakMinutes}')
    ..addListener(() {
      _note.breakMinutes = int.tryParse(_breakController.text) ?? 0;
    });

    _longBreakController = TextEditingController(text: '${_note.longBreakMinutes}')
    ..addListener(() {
      _note.longBreakMinutes = int.tryParse(_longBreakController.text) ?? 0;
    });

    _cyclesController = TextEditingController(text: '${_note.cycles}')
    ..addListener(() {
      _note.cycles = int.tryParse(_cyclesController.text) ?? 1;
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context, _note)),
        title: Text('Options', style: Theme.of(context).textTheme.displayMedium!),
      ),
      body: ContentContainer(
        maxWidth: 300.0,
        child: ListView(
          children: [
            const SizedBox(height: 50.0),
            TextField(
              controller: _focusController,
              style: Theme.of(context).textTheme.displaySmall!,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                prefixStyle: Theme.of(context).textTheme.displaySmall!,
                prefixText: 'focus: ',
                suffixText: 'm'
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _breakController,
              style: Theme.of(context).textTheme.displaySmall!,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                prefixStyle: Theme.of(context).textTheme.displaySmall!,
                prefixText: 'break: ',
                suffixText: 'm'
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _longBreakController,
              style: Theme.of(context).textTheme.displaySmall!,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                prefixStyle: Theme.of(context).textTheme.displaySmall!,
                prefixText: 'long break: ',
                suffixText: 'm'
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _cyclesController,
              style: Theme.of(context).textTheme.displaySmall!,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                prefixStyle: Theme.of(context).textTheme.displaySmall!,
                prefixText: 'cycles: '
              ),
            ),
            const SizedBox(height: 50.0),
            Center(child: SizedBox(
              width: 200.0,
              child: ElevatedButton.icon(
                onPressed: () => setState(() {
                  _focusController.text = '25';
                  _breakController.text = '5';
                  _longBreakController.text = '15';
                  _cyclesController.text = '4';
                }),
                icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                label: Text('Reset', style: Theme.of(context).textTheme.displaySmall!),
              )
            )),
            const SizedBox(height: 20.0,)
          ]
        ),
      ),
    ));
  }
}