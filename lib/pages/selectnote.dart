import 'package:flutter/material.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/notesview.dart';

class SelectNotePage extends StatelessWidget {

  final List<Note> notes;
  final List<String> alreadySelectedIds;

  const SelectNotePage({super.key, required this.notes, required this.alreadySelectedIds});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => Navigator.pop(context, null)),
        title: Text('Select note', style: Theme.of(context).textTheme.displayMedium!),
      ),
      body: ContentContainer(
        child: ListView(
          children: [
            const SizedBox(height: 10.0),
            NotesView(
              notes: notes,
              filter: (note) => !alreadySelectedIds.contains(note.id),
              onNotePressed: (note) => Navigator.pop(context, note)
            )
          ],
        )
      ),
    ));
  }

}
