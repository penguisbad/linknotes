import 'package:flutter/material.dart';

typedef StringCallback = void Function(String value);

class ChangeTitleDialog extends StatefulWidget {

  final StringCallback onTitleChanged;

  const ChangeTitleDialog({super.key, required this.onTitleChanged});

  @override
  State<ChangeTitleDialog> createState() => _ChangeTitleDialogState();

}

class _ChangeTitleDialogState extends State<ChangeTitleDialog> {
  
  var _newTitle = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change title', style: Theme.of(context).textTheme.displayMedium!),
      content: TextField(
        onChanged: (value) => _newTitle = value,
        style: Theme.of(context).textTheme.displaySmall!,
        decoration: const InputDecoration(
          hintText: 'new title'
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: Theme.of(context).textTheme.displaySmall!)
        ),
        ElevatedButton(
          onPressed: () {
            widget.onTitleChanged(_newTitle);
            Navigator.pop(context);
          },
          child: Text('Change', style: Theme.of(context).textTheme.displaySmall!)
        )
      ],
    );
  }

}