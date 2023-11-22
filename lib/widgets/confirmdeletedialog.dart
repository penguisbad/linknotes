import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatefulWidget {

  final VoidCallback onDelete;
  final String title;

  const ConfirmDeleteDialog({super.key, required this.onDelete, required this.title});

  @override
  State<ConfirmDeleteDialog> createState() => _ConfirmDeleteState();

}

class _ConfirmDeleteState extends State<ConfirmDeleteDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [
        Flexible(child: Text('Are you sure you want to delete ${widget.title}?',
          style: Theme.of(context).textTheme.displayMedium!,
          overflow: TextOverflow.visible))
      ]),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: Theme.of(context).textTheme.displaySmall!)
        ),
        ElevatedButton(
          onPressed: () {
            widget.onDelete();
            Navigator.pop(context);
          },
          child: Text('Delete', style: Theme.of(context).textTheme.displaySmall!)
        )
      ],
    );
  }

}