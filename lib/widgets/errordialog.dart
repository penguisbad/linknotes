import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {

  final String message;

  const ErrorDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Error', style: Theme.of(context).textTheme.displayMedium!),
      content: Text(message, style: Theme.of(context).textTheme.displaySmall!, overflow: TextOverflow.visible),
      actionsPadding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: Theme.of(context).textTheme.displaySmall!)
        )
      ]
    );
  }

}