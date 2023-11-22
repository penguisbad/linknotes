import 'package:flutter/material.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/model.dart';

class EditAlarmPage extends StatefulWidget {

  final Alarm alarm;
  final bool? creatingAlarm;

  const EditAlarmPage({super.key, required this.alarm, this.creatingAlarm});

  @override
  State<EditAlarmPage> createState() => _EditAlarmState();

}

class _EditAlarmState extends State<EditAlarmPage> {

  late Alarm _alarm;
  late TextEditingController _nameController;
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  

  @override
  void initState() {
    super.initState();
    _alarm = Alarm.withRepeat(
      name: widget.alarm.name, 
      hour: widget.alarm.hour,
      minute: widget.alarm.minute,
      amOrPm: widget.alarm.amOrPm,
      repeat: widget.alarm.repeat
    );

    _nameController = TextEditingController(text: _alarm.name)
    ..addListener(() { 
      _alarm.name = _nameController.text;
    });

    _hourController = TextEditingController(text: '${_alarm.hour}')
    ..addListener(() { 
      _alarm.hour = int.tryParse(_hourController.text) ?? 1;
    });

    _minuteController = TextEditingController(text: '${_alarm.minute}')
    ..addListener(() {
      _alarm.minute = int.tryParse(_minuteController.text) ?? 0;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context, 
          widget.creatingAlarm != null && widget.creatingAlarm! ? null : _alarm)),
        title: Text('${widget.creatingAlarm != null && widget.creatingAlarm! ? 'Create' : 'Edit'} Alarm', 
          style: Theme.of(context).textTheme.displayMedium!)
      ),
      body: ContentContainer(maxWidth: 300.0, child: ListView(
        children: [
          const SizedBox(height: 50.0),
          TextField(
            controller: _nameController,
            style: Theme.of(context).textTheme.displaySmall!,
            decoration: const InputDecoration(
              hintText: 'name'
            )
          ),
          const SizedBox(height: 10.0),
          Row(children: [
            Expanded(child: TextField(
              controller: _hourController,
              style: Theme.of(context).textTheme.displaySmall!,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'hour'
              ),
            )),
            const SizedBox(width: 5.0),
            Text(':', style: Theme.of(context).textTheme.displayMedium!),
            const SizedBox(width: 5.0),
            Expanded(child: TextField(
              controller: _minuteController,
              style: Theme.of(context).textTheme.displaySmall!,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'minute'
              )
            )),
            const SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: () => setState(() {
                if (_alarm.amOrPm == 'AM') {
                  _alarm.amOrPm = 'PM';
                } else {
                  _alarm.amOrPm = 'AM';
                }
              }),
              child: Text(_alarm.amOrPm, style: Theme.of(context).textTheme.displaySmall!)
            )
          ]),
          const SizedBox(height: 50.0),
          Row(children: [
            const SizedBox(width: 10.0),
            Text('Repeat every: ', style: Theme.of(context).textTheme.displayMedium!),
            
          ]),
          const SizedBox(height: 10.0),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: DayOfWeek.values.map((day) => Column(children: [
            day == DayOfWeek.monday ? const Divider(indent: 10.0, endIndent: 10.0) : Container(),
            TextButton(
              onPressed: () => setState(() {
                _alarm.repeat[day] = !(_alarm.repeat[day]!);
              }),
              child: Row(children: [
                Text((() {
                  switch (day) {
                    case DayOfWeek.monday:
                      return 'Monday';
                    case DayOfWeek.tuesday:
                      return 'Tuesday';
                    case DayOfWeek.wednesday:
                      return 'Wednesday';
                    case DayOfWeek.thursday:
                      return 'Thursday';
                    case DayOfWeek.friday:
                      return 'Friday';
                    case DayOfWeek.saturday:
                      return 'Saturday';
                    case DayOfWeek.sunday:
                      return 'Sunday';
                    default:
                      return '';
                  }
                })(), style: Theme.of(context).textTheme.displaySmall!),
                const Spacer(),
                Icon(_alarm.repeat[day]! ? Icons.check : Icons.close, color: Theme.of(context).primaryColor)
              ])
            ),
            const Divider(indent: 10.0, endIndent: 10.0,)
          ])).toList()),
          const SizedBox(height: 50.0),
          Center(child: SizedBox(
            width: 200.0,
            child: ElevatedButton(
              onPressed: () {
                if (widget.creatingAlarm != null && widget.creatingAlarm!) {
                  Navigator.pop(context, _alarm);
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: Text(widget.creatingAlarm != null && widget.creatingAlarm! ? 'Create' : 'Delete alarm',
                style: Theme.of(context).textTheme.displaySmall!)
            )
          ))
        ],
      )),
    ));
  }

}