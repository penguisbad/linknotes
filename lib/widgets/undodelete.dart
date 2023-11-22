import 'package:flutter/material.dart';

void showUndoDelete({required BuildContext context,required String title, required VoidCallback onUndoDelete}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 2),
    content: Row(children: [
      const SizedBox(width: 10.0),
      Expanded(child: Text('Deleted $title', style: Theme.of(context).textTheme.displaySmall!)),
      ElevatedButton(
        onPressed: onUndoDelete,
        child: Text('Undo', style: Theme.of(context).textTheme.displaySmall!)
      )
    ]),
  ));
}
