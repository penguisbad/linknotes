import 'package:flutter/material.dart';
import 'package:linknotes/model.dart';

typedef RepeatFrequencyCallback = void Function(RepeatFrequency repeatFrequency);

class RepeatPicker extends StatefulWidget {

  final RepeatFrequency initialValue;
  final RepeatFrequencyCallback onChanged;

  const RepeatPicker({super.key, required this.initialValue, required this.onChanged});

  @override
  State<RepeatPicker> createState() => _RepeatPickerState();
}

class _RepeatPickerState extends State<RepeatPicker> {

  late RepeatFrequency _repeatFrequency;

  @override
  void initState() {
    super.initState();
    _repeatFrequency = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Does not repeat', style: Theme.of(context).textTheme.displaySmall),
          leading: Radio<RepeatFrequency>(
            value: RepeatFrequency.doesnotrepeat,
            groupValue: _repeatFrequency,
            onChanged: (value) {
              setState(() {
                _repeatFrequency = value!;
              });
              widget.onChanged(_repeatFrequency);
            }
          ),
        ),
        ListTile(
          title: Text('Repeat weekly', style: Theme.of(context).textTheme.displaySmall!),
          leading: Radio<RepeatFrequency>(
            value: RepeatFrequency.weekly,
            groupValue: _repeatFrequency,
            onChanged: (value) {
              setState(() {
                _repeatFrequency = value!;
              });
              widget.onChanged(_repeatFrequency);
            }
          )
        ),
        ListTile(
          title: Text('Repeat monthly', style: Theme.of(context).textTheme.displaySmall!),
          leading: Radio<RepeatFrequency>(
            value: RepeatFrequency.monthly,
            groupValue: _repeatFrequency,
            onChanged: (value) {
              setState(() {
                _repeatFrequency = value!;
              });
              widget.onChanged(_repeatFrequency);
            },
          )
        ),
        ListTile(
          title: Text('Repeat yearly', style: Theme.of(context).textTheme.displaySmall!),
          leading: Radio<RepeatFrequency>(
            value: RepeatFrequency.yearly,
            groupValue: _repeatFrequency,
            onChanged: (value) {
              setState(() {
                _repeatFrequency = value!;
              });
              widget.onChanged(_repeatFrequency);
            },
          )
        )
      ],
    );
  }

}