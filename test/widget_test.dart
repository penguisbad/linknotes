import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknotes/pages/editcalendar.dart';
import 'package:linknotes/pages/editlist.dart';
import 'package:linknotes/pages/edittext.dart';
import 'package:linknotes/pages/edittimers.dart';
import 'package:linknotes/pages/notes.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/pages/viewtimers.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/nobackgroundtextfield.dart';
import 'package:linknotes/widgets/notesview.dart';

final testNotes = <Note>[
  TextNote(title: 'text note', text: 'test'),
  ListNote(title: 'list', items: ['1', '2', '3', '4'], isSublist: [false, true, false, false]),
  TimersNote(title: 'timers', timers: [Timer(name: 'test', duration: 300)]),
  AlarmsNote(title: 'alarms', alarms: [Alarm(name: 'test', hour: 3, minute: 15, amOrPm: 'PM')]),
  IncrementerNote(title: 'incrementer', value: 0),
  CalendarNote(title: 'calendar', events: [Event(
      name: 'test 1',
      time: DateTime(2023, 11, 23),
      duration: Duration.zero,
      allDay: true,
      repeatFrequency: RepeatFrequency.doesnotrepeat
    ),Event(
      name: 'test 2',
      time: DateTime(2023, 11, 23),
      duration: Duration.zero,
      allDay: true,
      repeatFrequency: RepeatFrequency.doesnotrepeat
    ),
    Event(
      name: 'test 3',
      time: DateTime(2023, 11, 23),
      duration: Duration.zero,
      allDay: true,
      repeatFrequency: RepeatFrequency.doesnotrepeat
    ),
    Event(
      name: 'test 4',
      time: DateTime(2023, 11, 24),
      duration: Duration.zero,
      allDay: true,
      repeatFrequency: RepeatFrequency.doesnotrepeat
    )])
];
void main() {
  group('Notes', () {
    testWidgets('Adding a note', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1500));

      await tester.pumpWidget(MaterialApp(
        home: NotesPage(notes: testNotes)
      ));
      expect(find.text('Notes'), findsOneWidget);
      
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add note'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'test note');
      final buttonFinder = find.byType(ElevatedButton);

      await tester.scrollUntilVisible(
        buttonFinder,
        100.0,
        scrollable: find.byType(Scrollable).first
      );
      await tester.pumpAndSettle();

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(NoteView), findsNWidgets(testNotes.length + 1));
      expect(find.text('test note'), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
    
    testWidgets('Deleting notes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1500));

      await tester.pumpWidget(MaterialApp(
        home: NotesPage(notes: testNotes)
      ));

      for (var i = 0; i < testNotes.length; i++) {
        await tester.tap(find.byType(NoteView).first);
        await tester.pumpAndSettle();

        if (testNotes[i] is TimersNote) {
          await tester.tap(find.ancestor(of: find.byIcon(Icons.edit), matching: find.byType(IconButton)));
          await tester.pumpAndSettle();
        }

        await tester.tap(find.ancestor(of: find.byIcon(Icons.more_vert), matching: find.byType(IconButton)));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.more_vert), findsNothing);
        expect(find.byIcon(Icons.close), findsWidgets);

        final deleteButton = find.byKey(const Key('Delete note menu button'));
        expect(deleteButton, findsOneWidget);

        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        final confirmDeleteButton = find.ancestor(of: find.text('Delete'), matching: find.byType(ElevatedButton));
        expect(confirmDeleteButton, findsOneWidget);

        await tester.tap(confirmDeleteButton);
        await tester.pumpAndSettle();

        expect(find.byType(NoteView), findsNWidgets(testNotes.length - i - 1));
      }
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    
    testWidgets('Changing note titles', (tester) async {
      
      await tester.binding.setSurfaceSize(const Size(800, 1500));

      await tester.pumpWidget(MaterialApp(
        home: NotesPage(notes: testNotes)
      ));

      final newTitles = ['new 1', 'new 2', 'new 3', 'new 4', 'new 5', 'new 6'];

      for (var i = 0; i < testNotes.length; i++) {
        await tester.tap(find.byType(NoteView).at(i));
        await tester.pumpAndSettle();

        final isTimerNote = find.text('timers').evaluate().isNotEmpty;

        if (isTimerNote) {
          await tester.tap(find.ancestor(of: find.byIcon(Icons.edit), matching: find.byType(IconButton)));
          await tester.pumpAndSettle();
        }

        await tester.tap(find.ancestor(of: find.byIcon(Icons.more_vert), matching: find.byType(IconButton)));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.more_vert), findsNothing);
        expect(find.byIcon(Icons.close), findsWidgets);

        final changeTitleButton = find.byKey(const Key('Change title menu button'));

        await tester.tap(changeTitleButton);
        await tester.pumpAndSettle();

        final textField = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField));

        await tester.enterText(textField, newTitles[i]);
        await tester.pumpAndSettle();

        final confirmChangeButton = find.ancestor(of: find.text('Change'), matching: find.byType(ElevatedButton));

        await tester.tap(confirmChangeButton);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(LBackButton));
        await tester.pumpAndSettle();

        if (isTimerNote) {
          await tester.tap(find.byType(LBackButton));
          await tester.pumpAndSettle();
        }

        expect(find.descendant(of: find.byType(NoteView), matching: find.text(newTitles[i])), findsOneWidget);

      }

      addTearDown(() => tester.binding.setSurfaceSize(null));
      
    });
  });

  group('Text', () {
    testWidgets('Editing text', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1500));

      await tester.pumpWidget(MaterialApp(
        home: EditTextPage(note: testNotes[0] as TextNote)
      ));

      expect(find.text('test'), findsOneWidget);

      await tester.enterText(find.byType(NoBackgroundTextField), '');
      await tester.pump();

      expect(find.text('type here'), findsOneWidget);

      await tester.enterText(find.byType(NoBackgroundTextField), 'asdf');
      await tester.pump();

      expect(find.text('asdf'), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });

  group('List', () {
    testWidgets('Adding an item', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1500));

      await tester.pumpWidget(MaterialApp(
        home: EditListPage(note: testNotes[1] as ListNote)
      ));

      await tester.tap(find.byType(NoBackgroundTextField).first);
      await tester.pump();

      await tester.tap(find.text('item'));
      await tester.pump();

      expect(find.byType(NoBackgroundTextField), findsNWidgets(5));

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('Deleting an item', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1500));

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
  
  group('Timers', () {
    testWidgets('Adding a timer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1500));

      await tester.pumpWidget(MaterialApp(
        home: EditTimersPage(note: testNotes[2] as TimersNote)
      ));

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(2), 'test 2');
      await tester.enterText(find.byType(TextField).at(3), '43');
      await tester.pump();

      expect(find.text('test 2'), findsOneWidget);
      expect(find.text('43'), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('Starting, pausing, and finishing a timer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1500));

      await tester.pumpWidget(MaterialApp(
        home: ViewTimersPage(note: testNotes[2] as TimersNote)
      ));

      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(seconds: 200));

      await tester.tap(find.text('Pause'));
      await tester.pump();

      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(seconds: 101));

      expect(find.text('Next'), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
  
  group('Calendar', () {
    testWidgets('Adding an event', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1500));

      await tester.pumpWidget(MaterialApp(
        home: EditCalendarPage(note: testNotes[5] as CalendarNote)
      ));

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
  
}