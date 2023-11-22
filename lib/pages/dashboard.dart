import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:linknotes/widgets/drawer.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/notesview.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/database.dart';

class DashboardPage extends StatefulWidget {

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardState();

}

class _DashboardState extends State<DashboardPage> {

  var _notes = <Note>[];
  var _loading = true;

  @override
  void initState() {
    super.initState();
    (() async {
      var retrievedNotes = await getNotes();
      setState(() {
        _notes = retrievedNotes;
        _loading = false;
      });
    })();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: const OpenDrawerButton(),
        title: Text('Dashboard', style: Theme.of(context).textTheme.displayMedium!)
      ),
      drawer: const LDrawer(),
      body: ContentContainer(
        child: !_loading ? ListView(children: [
          const SizedBox(height: 10.0),
          NotesView(notes: _notes, filter: (note) => note.isAddedToDashboard)
        ]) : const SizedBox.square(
          dimension: 50.0,
          child: LoadingIndicator(
            indicatorType: Indicator.circleStrokeSpin,
            colors: [Color.fromRGBO(70, 70, 100, 1)],
          )
        ),
      )
    ));
  }

}