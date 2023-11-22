import 'package:uuid/uuid.dart';

abstract class Note {

  String title;
  Link? link;
  late String id;
  late bool isAddedToDashboard;

  Note({required this.title, this.link}) {
    id = const Uuid().v8();
    isAddedToDashboard = false;
  }

  Note clone();
  List<String> asStringList();
  Note? asLinkedNote();
  
}

enum LinkType {
  replace, combine, multiply, distribute, parallel
}

class Link {
  LinkType linkType;
  Note source;
  bool combineNames;

  Link({required this.source, required this.linkType, required this.combineNames});
}

class ListNote extends Note {

  List<String> items;
  List<bool> isSublist;
  late List<bool> checked;
  bool showCheckboxes = true;

  ListNote({
    required super.title,
    super.link,
    required this.items,
    required this.isSublist
  }) {
    checked = items.map((_) => false).toList();
  }
  ListNote.withChecked({
    required super.title,
    super.link,
    required this.items,
    required this.isSublist,
    required this.checked,
  });

  @override
  ListNote clone() => ListNote.withChecked(
    title: title.substring(0, title.length),
    items: [...items],
    isSublist: [...isSublist],
    checked: [...checked],
  )..isAddedToDashboard = isAddedToDashboard
  ..id = id;

  @override
  ListNote? asLinkedNote() {
    throw UnimplementedError();
  }
  
  @override
  List<String> asStringList() => items;

}

class TextNote extends Note {

  String text;

  TextNote({required super.title, super.link, required this.text});

  @override
  TextNote clone() => TextNote(
    title: title.substring(0, title.length),
    text: text.substring(0, text.length)
  )..isAddedToDashboard = isAddedToDashboard
  ..id = id;

  @override
  TextNote? asLinkedNote() {
    throw UnimplementedError();
  }
  
  @override
  List<String> asStringList() => [text];

}

class Timer {
  String name;
  int duration;
  late int timeLeft;
  late String id;

  Timer({required this.name, required this.duration}) {
    timeLeft = duration;
    id = const Uuid().v8();
  }
  
  String get minutesAndSeconds {
    var minutes = '${(timeLeft / 60).floor()}';
    var seconds = '${timeLeft % 60}';
    if (minutes.length == 1) {
      minutes = '0$minutes';
    }
    if (seconds.length == 1) {
      seconds = '0$seconds';
    }
    return '$minutes:$seconds';
  }

  reset() => timeLeft = duration;
}

class TimersNote extends Note {

  List<Timer> timers;
  int index = 0;
  Timer? get currentTimer => timers.isNotEmpty ? timers[index] : null;

  TimersNote({required super.title, super.link, required this.timers});
  TimersNote.atIndex({required super.title, super.link, required this.timers, required this.index});

  @override
  TimersNote clone() => TimersNote.atIndex(
    title: title.substring(0, title.length),
    timers: [...timers],
    index: index
  )..isAddedToDashboard = isAddedToDashboard
  ..id = id;

  @override
  TimersNote? asLinkedNote() {
    throw UnimplementedError();
  }

  nextTimer() {
    if (currentTimer == null) {
      return;
    }
    index++;
    if (index == timers.length) {
      index = 0;
    }
    currentTimer!.reset();
  }
  
  @override
  List<String> asStringList() => timers.map(
    (timer) => '${timer.name} - ${timer.minutesAndSeconds}'
  ).toList();

}

enum DayOfWeek {
  monday, tuesday, wednesday,
  thursday, friday,
  saturday, sunday,
}

class Alarm {
  String name;
  int hour;
  int minute;
  String amOrPm;
  late Map<DayOfWeek, bool> repeat;
  late String id;

  Alarm({required this.name, required this.hour, required this.amOrPm, required this.minute}) {
    repeat = {};
    for (final day in DayOfWeek.values) {
      repeat[day] = false;
    }
    id = const Uuid().v8();
  }
  Alarm.withRepeat({required this.name, required this.hour, required this.minute, required this.amOrPm, required this.repeat}) {
    id = const Uuid().v8();
  }

  String get time {
    var minuteString = '$minute';
    if (minuteString.length == 1) {
      minuteString = '0$minuteString';
    }
    return '$hour:$minuteString $amOrPm';
  }
}

class AlarmsNote extends Note {

  List<Alarm> alarms;

  AlarmsNote({required super.title, super.link, required this.alarms});

  @override
  AlarmsNote clone() => AlarmsNote(
    title: title.substring(0, title.length),
    alarms: [...alarms]
  )..isAddedToDashboard = isAddedToDashboard
  ..id = id;

  @override
  AlarmsNote? asLinkedNote() {
    throw UnimplementedError();
  }
  
  @override
  List<String> asStringList() => alarms.map(
    (alarm) => '${alarm.name} - ${alarm.time}'
  ).toList();

}

class IncrementerNote extends Note {

  int value;

  IncrementerNote({required super.title, super.link, required this.value});

  increment() => value++;
  decrement() => value--;

  @override
  IncrementerNote clone() => IncrementerNote(
    title: title.substring(0, title.length),
    value: value
  )..isAddedToDashboard = isAddedToDashboard
  ..id = id;

  @override
  IncrementerNote? asLinkedNote() {
    throw UnimplementedError();
  }
  
  @override
  List<String> asStringList() => List.generate(value, (index) => '${index + 1}').toList();
}

enum RepeatFrequency {
  doesnotrepeat, weekly, monthly, yearly
}

class Event {
  String name;
  DateTime time;
  Duration duration;
  bool allDay;
  RepeatFrequency repeatFrequency;
  late String id;
  
  Event({required this.name, required this.time, required this.duration, required this.allDay, required this.repeatFrequency}) {
    id = const Uuid().v8();
  }
}

String toOrdinal(int number) {
  switch (number % 10) {
    case 1:
      return '${number}st';
    case 2:
      return '${number}nd';
    case 3:
      return '${number}rd';
    default:
      return '${number}th';
  }
}
String getMonth(int month) {
  return ['January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'][month - 1];
}


String getDateTimeString(DateTime dateTime) {
  final month = getMonth(dateTime.month);
  return '$month ${toOrdinal(dateTime.day)}, ${dateTime.year}';
}


class CalendarNote extends Note {

  List<Event> events;

  CalendarNote({required super.title, required this.events});

  @override
  CalendarNote clone() => CalendarNote(
    title: title.substring(0, title.length), 
    events: [...events]
  )..isAddedToDashboard = isAddedToDashboard
  ..id = id;

  @override
  CalendarNote? asLinkedNote() {
    throw UnimplementedError();
  }
  
  

  @override
  List<String> asStringList() => events.map(
    (event) => '${event.name} - ${(() {
      if (event.repeatFrequency == RepeatFrequency.weekly) {
        return 'Every ${['monday', 'tuesday', 'wednesday', 'thursday',
        'friday', 'saturday'][event.time.weekday - 1]}';
      } else if (event.repeatFrequency == RepeatFrequency.monthly) {
        return 'Every ${toOrdinal(event.time.day)}';
      } else if (event.repeatFrequency == RepeatFrequency.yearly) {
        return 'Every ${getMonth(event.time.month)} ${toOrdinal(event.time.day)}';
      }
      return '${getMonth(event.time.month)} ${toOrdinal(event.time.day)} ${event.time.year}';
    })()}'
  ).toList();
}

class Task {
  String name;
  String? details;
  DateTime? dueDate;
  bool isCompleted = false;
  RepeatFrequency repeatFrequency;
  late String id;

  Task({required this.name, this.details, this.dueDate, required this.repeatFrequency}) {
    id = const Uuid().v8();
  }
}

class TasksNote extends Note {

  List<Task> tasks;

  TasksNote({required super.title, required this.tasks});

  List<Task> get completedTasks => tasks.where((task) => task.isCompleted).toList();

  @override
  TasksNote clone() => TasksNote(
    title: title.substring(0, title.length), tasks: [...tasks]
  )..isAddedToDashboard = isAddedToDashboard
  ..id = id;

  @override
  Note? asLinkedNote() {
    throw UnimplementedError();
  }

  @override
  List<String> asStringList() {
    throw UnimplementedError();
  }
}

enum PomodoroState { focus, shortBreak, longBreak }

class PomodoroNote extends Note {
  int cycles = 4;
  int focusMinutes = 25;
  int breakMinutes = 5;
  int longBreakMinutes = 15;
  List<String> tasks;
  PomodoroState currentState = PomodoroState.focus;
  int currentIndex = 0;
  int currentCycle = 1;
  PomodoroNote({required super.title, required this.tasks});

  String get currentName {
    print('lsdkjf');
    print(currentState);
    if (currentState == PomodoroState.shortBreak) {
      return 'Short break';
    } else if (currentState == PomodoroState.longBreak) {
      return 'Long break';
    }
    return tasks[currentIndex];
  }
  int get currentDuration {
    if (currentState == PomodoroState.shortBreak) {
      return breakMinutes * 60;
    } else if (currentState == PomodoroState.longBreak) {
      return longBreakMinutes * 60;
    }
    return focusMinutes * 60;
  }

  void next() {
    if (currentState == PomodoroState.focus) {
      if (currentCycle == cycles) {
        currentState = PomodoroState.longBreak;
      } else {
        currentState = PomodoroState.shortBreak;
      }
    } else if (currentState == PomodoroState.shortBreak) {
      currentState = PomodoroState.focus;
      currentCycle++;
    } else if (currentState == PomodoroState.longBreak) {
      currentState = PomodoroState.focus;
      currentCycle = 1;
    }
  }

  void nextTask() {
    currentIndex++;
    if (currentIndex == tasks.length) {
      currentIndex = 0;
    }
    currentState = PomodoroState.focus;
    currentCycle = 1;
  }

  void reset() {
    currentIndex = 0;
    currentCycle = 1;
    currentState = PomodoroState.focus;
  }

  @override
  PomodoroNote clone() => PomodoroNote(
    title: title.substring(0, title.length),
    tasks: [...tasks]
  )..isAddedToDashboard = isAddedToDashboard
  ..currentIndex = currentIndex
  ..currentState = currentState
  ..currentCycle = currentCycle
  ..focusMinutes = focusMinutes
  ..breakMinutes = breakMinutes
  ..longBreakMinutes = longBreakMinutes
  ..id = id;

  @override
  Note? asLinkedNote() {
    throw UnimplementedError();
  }
  
  @override
  List<String> asStringList() {
    throw UnimplementedError();
  }
}

class Folder {
  String title;
  List<String> noteIds;
  late String id;

  Folder({required this.title, required this.noteIds}) {
    id = const Uuid().v8();
  }

  Folder clone() => Folder(
    title: title.substring(0, title.length),
    noteIds: [...noteIds]
  )..id = id;
}

typedef GetFolderCallback = Future<Folder?> Function();

Future<List<Folder>> updateFolders({
  required List<Folder> folders,
  required String noteId,
  required bool addedToFolder,
  required GetFolderCallback getFolder}) async {

  if (addedToFolder) {
    final folderIndex = folders.indexWhere((f) => f.noteIds.contains(noteId));
    folders[folderIndex].noteIds.removeWhere((element) => element == noteId);
  } else {
    final folder = await getFolder();
    if (!(folder == null)) {
      final folderIndex = folders.indexWhere((f) => f.id == folder.id);
      folders[folderIndex].noteIds.add(noteId);
    }
  }

  return folders;

}

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
    )]
  ),
  TasksNote(
    title: 'tasks',
    tasks: [
      Task(
        name: 'task 1',
        repeatFrequency: RepeatFrequency.doesnotrepeat
      ),
    ]
  ),
  PomodoroNote(
    title: 'pomodoro',
    tasks: ['1', '2', '3']
  )
];

final testFolders = <Folder>[
  Folder(
    title: 'test',
    noteIds: ['20231115-1605-8705-b863-615496d5f930', '20231115-1605-8510-9917-7c64d7afcd09']
  )
];