import 'package:flutter/material.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/repeatpicker.dart';

class EditEventPage extends StatefulWidget {

  final Event event;
  final bool creatingEvent;

  const EditEventPage({super.key, required this.event, required this.creatingEvent});

  @override
  State<EditEventPage> createState() => _EditEventState();

}

class _EditEventState extends State<EditEventPage> {

  late Event _event;
  late TextEditingController _nameController;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    _event = Event(
      name: widget.event.name,
      time: widget.event.time,
      duration: widget.event.duration,
      allDay: widget.event.allDay,
      repeatFrequency: widget.event.repeatFrequency,
    )
    ..id = widget.event.id;

    _nameController = TextEditingController(text: _event.name)
    ..addListener(() {
      _event.name = _nameController.text;
    });

    _hoursController = TextEditingController(text: '${_event.duration.inHours}')
    ..addListener(() {
      _event.duration = Duration(
        hours: int.tryParse(_hoursController.text) ?? 0,
        minutes: _event.duration.inMinutes % 60
      );
    });

    _minutesController = TextEditingController(text: '${_event.duration.inMinutes % 60}')
    ..addListener(() {
      _event.duration = Duration(
        hours: _event.duration.inHours,
        minutes: (int.tryParse(_minutesController.text) ?? 0) % 60
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () {
          if (widget.creatingEvent) {
            Navigator.pop(context, null);
          } else {
            Navigator.pop(context, _event);
          }
        }),
        title: Text('${widget.creatingEvent ? 'Create' : 'Edit'} event', style: Theme.of(context).textTheme.displayMedium!)
      ),
      body: ContentContainer(maxWidth: 300.0, child: ListView(
        children: [
          const SizedBox(height: 50.0),
          TextField(
            controller: _nameController,
            style: Theme.of(context).textTheme.displaySmall!,
            decoration: const InputDecoration(
              hintText: 'name'
            ),
          ),
          const SizedBox(height: 50.0),
          Center(child: SizedBox(
            width: 200.0,
            child: ElevatedButton(
              onPressed: () => setState(() {
                _event.allDay = !_event.allDay;
              }),
              child: Text(_event.allDay ? 'All day' : 'Specific duration', style: Theme.of(context).textTheme.displaySmall!)
            )
          )),
          const SizedBox(height: 10.0),
          _event.allDay ? Container() : Row(children: [
            Expanded(child: TextField(
              controller: _hoursController,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.displaySmall!,
              decoration: const InputDecoration(
                suffixText: 'h'
              ),
            )),
            const SizedBox(width: 5.0),
            Expanded(child: TextField(
              controller: _minutesController,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.displaySmall!,
              decoration: const InputDecoration(
                suffixText: 'm'
              )
            ))
          ]),
          const SizedBox(height: 20.0),
          RepeatPicker(
            initialValue: RepeatFrequency.doesnotrepeat,
            onChanged: (value) {
              _event.repeatFrequency = value;
            }
          ),
          const SizedBox(height: 50.0),
          Center(child: SizedBox(
            width: 200.0,
            child: ElevatedButton(
              onPressed: () {
                if (widget.creatingEvent) {
                  Navigator.pop(context, _event);
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: Text(widget.creatingEvent ? 'Create' : 'Delete event', style: Theme.of(context).textTheme.displaySmall!)
            )
          )),
          const SizedBox(height: 10.0)
        ]
      ))
    ));
  }

}