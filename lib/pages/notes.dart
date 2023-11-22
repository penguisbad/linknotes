import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:linknotes/widgets/notesview.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/drawer.dart';
import 'package:linknotes/pages/addnote.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';

class NotesPage extends StatefulWidget {

  final List<Note>? notes;

  const NotesPage({super.key, this.notes});

  @override
  State<NotesPage> createState() => _NotesState();

}

class _NotesState extends State<NotesPage> with SingleTickerProviderStateMixin {

  var _notes = <Note>[];
  var _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.notes == null) {
      
      (() async {
        var retrievedNotes = await getNotes();
        setState(() {
          _notes = retrievedNotes;
          _loading = false;
        });
      })();
    } else {
      _notes = [...widget.notes!];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: const OpenDrawerButton(),
        title: Text('Notes', style: Theme.of(context).textTheme.displayMedium!)
      ),
      floatingActionButton: FloatingActionButton(
        
        onPressed: () async {
          final newNote = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => const AddNotePage(),
            fullscreenDialog: true
          ));
          if (!mounted || newNote == null) return;
          setState(() {
            _notes.add(newNote);
          });
          saveNotes(notes: _notes);
          
        },
        child: Icon(Icons.add, color: Theme.of(context).primaryColor)
      ),
      drawer: const LDrawer(),
      body: ContentContainer(
        child: !_loading ? ListView(children: [
          const SizedBox(height: 10.0),
          NotesView(notes: _notes) 
        ]) : SizedBox.square(
          dimension: 50.0,
          child: LoadingIndicator(
            indicatorType: Indicator.circleStrokeSpin,
            colors: [Theme.of(context).hintColor],
          )
        )
      )
    ));
  }
}