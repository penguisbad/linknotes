import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linknotes/model.dart';

void saveNotes({required List<Note> notes}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'e';
  if (userId == 'none') {
    return;
  }
  final ref = FirebaseDatabase.instance.ref('notes/$userId');
  
  var ids = <String>[];
  var titles = <String, String>{};
  var types = <String, String>{};
  var addedToDashboard = <String, bool>{};

  var text = <String, String>{};

  var listItems = <String, List<String>>{};
  var listChecked = <String, List<bool>>{};
  var isSublist = <String, List<bool>>{};

  var noteTimerIds = <String, List<String>>{};
  var timerNames = <String, String>{};
  var timerDurations = <String, int>{};

  var noteAlarmIds = <String, List<String>>{};
  var alarmNames = <String, String>{};
  var alarmHours = <String, int>{};
  var alarmMinutes = <String, int>{};
  var alarmAmOrPm = <String, String>{};

  var incrementerValues = <String, int>{};

  var noteEventIds = <String, List<String>>{};
  var eventNames = <String, String>{};
  var eventTimes = <String, String>{};
  var eventDurationHours = <String, int>{};
  var eventDurationMinutes = <String, int>{};
  var eventAllDay = <String, bool>{};
  var eventRepeatFrequency = <String, int>{};

  var noteTaskIds = <String, List<String>>{};
  var taskNames = <String, String>{};
  var taskDetails = <String, String>{};
  var taskDueDates = <String, String>{};
  var taskIsCompleted = <String, bool>{};
  var taskRepeatFrequency = <String, int>{};

  var pomodoroTasks = <String, List<String>>{};
  var pomodoroCycles = <String, int>{};
  var pomodoroBreak = <String, int>{};
  var pomodoroLongBreak = <String, int>{};
  var pomodoroState = <String, int>{};
  var pomodoroIndex = <String, int>{};
  var pomodoroCycle = <String, int>{};

  for (final note in notes) {
    ids.add(note.id);
    titles[note.id] = note.title;
    addedToDashboard[note.id] = note.isAddedToDashboard;

    if (note is TextNote) {
      types[note.id] = 'text';
      text[note.id] = note.text;
    } else if (note is ListNote) {
      types[note.id] = 'list';
      listItems[note.id] = note.items;
      listChecked[note.id] = note.checked;
      isSublist[note.id] = note.isSublist;
    } else if (note is TimersNote) {
      types[note.id] = 'timers';
      noteTimerIds[note.id] = [];
      for (final timer in note.timers) {
        noteTimerIds[note.id]!.add(timer.id);
        timerNames[timer.id] = timer.name;
        timerDurations[timer.id] = timer.duration;
      }
    } else if (note is AlarmsNote) {
      types[note.id] = 'alarms';
      noteAlarmIds[note.id] = [];
      for (final alarm in note.alarms) {
        noteAlarmIds[note.id]!.add(alarm.id);
        alarmNames[alarm.id] = alarm.name;
        alarmHours[alarm.id] = alarm.hour;
        alarmMinutes[alarm.id] = alarm.minute;
        alarmAmOrPm[alarm.id] = alarm.amOrPm;
      }
    } else if (note is IncrementerNote) {
      types[note.id] = 'incrementer';
      incrementerValues[note.id] = note.value;
    } else if (note is CalendarNote) {
      types[note.id] = 'calendar';
      noteEventIds[note.id] = [];
      for (final event in note.events) {
        noteEventIds[note.id]!.add(event.id);
        eventNames[event.id] = event.name;
        eventTimes[event.id] = event.time.toString();
        eventDurationHours[event.id] = event.duration.inHours;
        eventDurationMinutes[event.id] = event.duration.inMinutes % 60;
        eventAllDay[event.id] = event.allDay;
        eventRepeatFrequency[event.id] = RepeatFrequency.values.indexOf(event.repeatFrequency);
      }
    } else if (note is TasksNote) {
      types[note.id] = 'tasks';
      noteTaskIds[note.id] = [];
      for (final task in note.tasks) {
        noteTaskIds[note.id]!.add(task.id);
        taskNames[task.id] = task.name;
        taskIsCompleted[task.id] = task.isCompleted;
        taskRepeatFrequency[task.id] = RepeatFrequency.values.indexOf(task.repeatFrequency);
        if (task.details != null) {
          taskDetails[task.id] = task.details!;
        }
        if (task.dueDate != null) {
          taskDueDates[task.id] = task.dueDate!.toString();
        }
      }
    } else if (note is PomodoroNote) {
      types[note.id] = 'pomodoro';
      pomodoroTasks[note.id] = note.tasks;
      pomodoroBreak[note.id] = note.breakMinutes;
      pomodoroLongBreak[note.id] = note.longBreakMinutes;
      pomodoroCycles[note.id] = note.cycles;
      pomodoroState[note.id] = PomodoroState.values.indexOf(note.currentState);
      pomodoroIndex[note.id] = note.currentIndex;
      pomodoroCycle[note.id] = note.currentCycle;
    }
  }

  await ref.child('ids').set(ids);
  await ref.child('titles').set(titles);
  await ref.child('types').set(types);
  await ref.child('addedToDashboard').set(addedToDashboard);
  await ref.child('text').set(text);
  await ref.child('listItems').set(listItems);
  await ref.child('listChecked').set(listChecked);
  await ref.child('isSublist').set(isSublist);
  await ref.child('noteTimerIds').set(noteTimerIds);
  await ref.child('timerNames').set(timerNames);
  await ref.child('timerDurations').set(timerDurations);
  await ref.child('noteAlarmIds').set(noteAlarmIds);
  await ref.child('alarmNames').set(alarmNames);
  await ref.child('alarmHours').set(alarmHours);
  await ref.child('alarmMinutes').set(alarmMinutes);
  await ref.child('alarmAmOrPm').set(alarmAmOrPm);
  await ref.child('incrementerValues').set(incrementerValues);
  await ref.child('noteEventIds').set(noteEventIds);
  await ref.child('eventNames').set(eventNames);
  await ref.child('eventTimes').set(eventTimes);
  await ref.child('eventDurationHours').set(eventDurationHours);
  await ref.child('eventDurationMinutes').set(eventDurationMinutes);
  await ref.child('eventAllDay').set(eventAllDay);
  await ref.child('eventRepeatFrequency').set(eventRepeatFrequency);
  await ref.child('noteTaskIds').set(noteTaskIds);
  await ref.child('taskNames').set(taskNames);
  await ref.child('taskDetails').set(taskDetails);
  await ref.child('taskDueDates').set(taskDueDates);
  await ref.child('taskIsCompleted').set(taskIsCompleted);
  await ref.child('taskRepeatFrequency').set(taskRepeatFrequency);
  await ref.child('pomodoroTasks').set(pomodoroTasks);
  await ref.child('pomodoroBreak').set(pomodoroBreak);
  await ref.child('pomodoroLongBreak').set(pomodoroLongBreak);
  await ref.child('pomodoroCycles').set(pomodoroCycles);
  await ref.child('pomodoroState').set(pomodoroState);
  await ref.child('pomodoroIndex').set(pomodoroIndex);
  await ref.child('pomodoroCycle').set(pomodoroCycle);
}

Future<List<Note>> getNotes() {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  return getNotesForUserId(userId);
}

Future<List<Note>> getAllNotes() async {
  final ref = FirebaseDatabase.instance.ref();
  final userIds = (await ref.child('userIds').get()).children.map(
    (userIdSnapshot) => userIdSnapshot.value! as String
  );
  var notes = <Note>[];
  for (final userId in userIds) {
    notes.addAll(await getNotesForUserId(userId));
  }
  return notes;
}

Future<List<Note>> getNotesForUserId(String userId) async {
  final ref = FirebaseDatabase.instance.ref('notes/$userId');

  var notes = <Note>[];

  final ids = (await ref.child('ids').get()).children.map(
    (idSnapshot) => idSnapshot.value! as String
  );

  for (final id in ids) {
    final title = (await ref.child('titles/$id').get()).value! as String;
    final type = (await ref.child('types/$id').get()).value! as String;
    final isAddedToDashboard = (await ref.child('addedToDashboard/$id').get()).value! as bool;

    late Note newNote;

    if (type == 'text') {
      final text = (await ref.child('text/$id').get()).value! as String;
      newNote = TextNote(title: title, text: text);
    } else if (type == 'list') {
      final items = (await ref.child('listItems/$id').get()).children.map(
        (itemSnapshot) => itemSnapshot.value! as String
      ).toList();
      final checked = (await ref.child('listChecked/$id').get()).children.map(
        (checkedSnapshot) => checkedSnapshot.value! as bool
      ).toList();
      final isSublist = (await ref.child('isSublist/$id').get()).children.map(
        (isSublistSnapshot) => isSublistSnapshot.value! as bool
      ).toList();
      newNote = ListNote.withChecked(title: title, items: items, isSublist: isSublist, checked: checked);
    } else if (type == 'timers') {
      newNote = TimersNote(title: title, timers: []);
      final timerIds = (await ref.child('noteTimerIds/$id').get()).children.map(
        (timerIdSnapshot) => timerIdSnapshot.value! as String
      );
      for (final timerId in timerIds) {
        final timerName = (await ref.child('timerNames/$timerId').get()).value! as String;
        final timerDuration = (await ref.child('timerDurations/$timerId').get()).value! as int;
        (newNote as TimersNote).timers.add(Timer(
          name: timerName,
          duration: timerDuration
        ));
      }
    } else if (type == 'alarms') {
      newNote = AlarmsNote(title: title, alarms: []);
      final alarmIds = (await ref.child('noteAlarmIds/$id').get()).children.map(
        (alarmIdSnapshot) => alarmIdSnapshot.value! as String
      );
      for (final alarmId in alarmIds) {
        final alarmName = (await ref.child('alarmNames/$alarmId').get()).value! as String;
        final alarmHour = (await ref.child('alarmHours/$alarmId').get()).value! as int;
        final alarmMinute = (await ref.child('alarmMinutes/$alarmId').get()).value! as int;
        final amOrPm = (await ref.child('alarmAmOrPm/$alarmId').get()).value! as String;
        (newNote as AlarmsNote).alarms.add(Alarm(
          name: alarmName,
          hour: alarmHour,
          minute: alarmMinute,
          amOrPm: amOrPm
        ));
      }
    } else if (type == 'incrementer') {
      final incrementerValue = (await ref.child('incrementerValues/$id').get()).value! as int;
      newNote = IncrementerNote(title: title, value: incrementerValue);
    } else if (type == 'calendar') {
      newNote = CalendarNote(title: title, events: []);
      final eventIds = (await ref.child('noteEventIds/$id').get()).children.map(
        (eventIdSnapshot) => eventIdSnapshot.value! as String
      );
      for (final eventId in eventIds) {
        final eventName = (await ref.child('eventNames/$eventId').get()).value! as String;
        final eventHours = (await ref.child('eventDurationHours/$eventId').get()).value! as int;
        final eventTime = DateTime.parse((await ref.child('eventTimes/$eventId').get()).value! as String);
        final eventMinutes = (await ref.child('eventDurationMinutes/$eventId').get()).value! as int;
        final allDay = (await ref.child('eventAllDay/$eventId').get()).value! as bool;
        final repeatFrequency = RepeatFrequency.values[(await ref.child('eventRepeatFrequency/$eventId').get()).value! as int];
        (newNote as CalendarNote).events.add(Event(
          name: eventName,
          time: eventTime,
          duration: Duration(hours: eventHours, minutes: eventMinutes),
          allDay: allDay,
          repeatFrequency: repeatFrequency
        ));
      }
    } else if (type == 'tasks') {
      newNote = TasksNote(title: title, tasks: []);
      final taskIds = (await ref.child('noteTaskIds/$id').get()).children.map(
        (taskIdSnapshot) => taskIdSnapshot.value! as String
      );
      for (final taskId in taskIds) {
        
        final taskName = (await ref.child('taskNames/$taskId').get()).value! as String;
        final isCompleted = (await ref.child('taskIsCompleted/$taskId').get()).value! as bool;
        final repeatFrequency = RepeatFrequency.values[(await ref.child('taskRepeatFrequency/$taskId').get()).value! as int];
        var newTask = Task(
          name: taskName,
          repeatFrequency: repeatFrequency
        )..isCompleted = isCompleted;
        final detailsSnapshot = await ref.child('taskDetails/$taskId').get();
        final dueDateSnapshot = await ref.child('taskDueDates/$taskId').get();
        if (detailsSnapshot.exists) {
          newTask.details = detailsSnapshot.value! as String;
        }
        if (dueDateSnapshot.exists) {
          newTask.dueDate = DateTime.parse(dueDateSnapshot.value! as String);
        }
        (newNote as TasksNote).tasks.add(newTask);
      }
    } else if (type == 'pomodoro') {
      final tasks = (await ref.child('pomodoroTasks/$id').get()).children.map(
        (taskSnapshot) => taskSnapshot.value! as String
      ).toList();
      final breakMinutes = (await ref.child('pomodoroBreak/$id').get()).value! as int;
      final longBreakMinutes = (await ref.child('pomodoroLongBreak/$id').get()).value! as int;
      final cycles = (await ref.child('pomodoroCycles/$id').get()).value! as int;
      final state = PomodoroState.values[(await ref.child('pomodoroState/$id').get()).value! as int];
      final index = (await ref.child('pomodoroIndex/$id').get()).value! as int;
      final cycle = (await ref.child('pomodoroCycle/$id').get()).value! as int;

      newNote = PomodoroNote(title: title, tasks: tasks)
      ..breakMinutes = breakMinutes
      ..longBreakMinutes = longBreakMinutes
      ..cycles = cycles
      ..currentState = state
      ..currentIndex = index
      ..currentCycle = cycle;
    }

    newNote.id = id;
    newNote.isAddedToDashboard = isAddedToDashboard;
    notes.add(newNote);
  }

  return notes;
}

void saveFolders({required List<Folder> folders}) async {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final ref = FirebaseDatabase.instance.ref('folders/$userId');

  var ids = <String>[];
  var titles = <String, String>{};
  var notesIds = <String, List<String>>{};

  for (final folder in folders) {
    ids.add(folder.id);
    titles[folder.id] = folder.title;
    notesIds[folder.id] = folder.noteIds;
  }

  await ref.child('ids').set(ids);
  await ref.child('titles').set(titles);
  await ref.child('noteIds').set(notesIds);
}

Future<List<Folder>> getFolders() async {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final ref = FirebaseDatabase.instance.ref('folders/$userId');
  final ids = (await ref.child('ids').get()).children.map(
    (idSnapshot) => idSnapshot.value! as String
  );

  var folders = <Folder>[];

  for (final id in ids) {
    final title = (await ref.child('titles/$id').get()).value! as String;
    final noteIds = (await ref.child('noteIds/$id').get()).children.map(
      (noteIdSnapshot) => noteIdSnapshot.value! as String
    ).toList();

    var newFolder = Folder(title: title, noteIds: noteIds)
    ..id = id;

    folders.add(newFolder);
  }

  return folders;
}