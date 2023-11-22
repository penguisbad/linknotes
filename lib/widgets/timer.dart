import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {

  final ValueNotifier<String> name;
  final ValueNotifier<int> duration;
  final VoidCallback onNextTimer;

  const TimerWidget({
    super.key,
    required this.name,
    required this.duration,
    required this.onNextTimer
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();

}

enum TimerState { active, inactive, paused, finished }

class _TimerWidgetState extends State<TimerWidget> {

  var _timerState = TimerState.inactive;

  late String _name;
  late int _timeLeft;

  @override
  void initState() {
    super.initState();
    _name = widget.name.value;
    _timeLeft = widget.duration.value;
    widget.name.addListener(() => setState(() {
      _name = widget.name.value;
    }));
    widget.duration.addListener(() => setState(() {
      _timeLeft = widget.duration.value;
    }));
  }

  void _startTimer() async {
    setState(() {
      _timerState = TimerState.active;
    });
    while (_timeLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (_timerState == TimerState.inactive) {
        return;
      }
      if (_timerState == TimerState.paused) {
        continue;
      }
      try {
        setState(() {
          _timeLeft--;
        });
      } catch (_) {
        return;
      }
      
    }
    setState(() {
      _timerState = TimerState.finished;
    });
    
  }

  String _minutesAndSeconds(int time) {
    var minutes = '${(time / 60).floor()}';
    var seconds = '${time % 60}';
    if (minutes.length == 1) {
      minutes = '0$minutes';
    }
    if (seconds.length == 1) {
      seconds = '0$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(_name, style: Theme.of(context).textTheme.displayMedium!),
      const SizedBox(height: 10.0),
      Text(_minutesAndSeconds(_timeLeft), style: Theme.of(context).textTheme.labelMedium!),
      const SizedBox(height: 50.0),
      Center(child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            switch (_timerState) {
              case TimerState.inactive:
                _startTimer();
                break;
              case TimerState.active:
                setState(() => _timerState = TimerState.paused);
                break;
              case TimerState.paused:
                setState(() => _timerState = TimerState.active);
                break;
              case TimerState.finished:
                setState(() {
                  widget.onNextTimer();
                  _timerState = TimerState.inactive; 
                });
                break;
              default:
                break;
            }
          },
          child: Text((() {
            switch (_timerState) {
              case TimerState.inactive:
                return 'Start';
              case TimerState.active:
                return 'Pause';
              case TimerState.paused:
                return 'Continue';
              case TimerState.finished:
                return 'Next';
              default:
                return 'Start';
            }
          })(), 
          style: Theme.of(context).textTheme.displaySmall!
          )
        )
      )),
      const SizedBox(height: 10.0),
      Center(child: SizedBox(
        width: 200.0,
        child: ElevatedButton(
          onPressed: () => setState(() {
            widget.onNextTimer();
            _timerState = TimerState.inactive;
          }),
          child: Text('Skip', style: Theme.of(context).textTheme.displaySmall!)
        )
      ))
    ]);
  }
}