import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:linknotes/model.dart';
import 'package:linknotes/widgets/backbutton.dart';
import 'package:linknotes/widgets/contentcontainer.dart';
import 'package:linknotes/widgets/repeatpicker.dart';

class EditTaskPage extends StatefulWidget {

  final Task task;
  final bool creatingTask;

  const EditTaskPage({super.key, required this.task, required this.creatingTask});

  @override
  State<EditTaskPage> createState() => _EditTaskState();

}

class _EditTaskState extends State<EditTaskPage> {

  late Task _task;
  late TextEditingController _nameController;
  late TextEditingController _detailsController;
  

  @override
  void initState() {
    super.initState();
    _task = Task(
      name: widget.task.name,
      details: widget.task.details,
      dueDate: widget.task.dueDate,
      repeatFrequency: widget.task.repeatFrequency
    )..id = widget.task.id
    ..isCompleted = widget.task.isCompleted;

    _nameController = TextEditingController(text: _task.name)
    ..addListener(() {
      _task.name = _nameController.text;
    });

    _detailsController = TextEditingController(text: _task.details)
    ..addListener(() {
      if (_detailsController.text == '') {
        _task.details = null;
        return;
      }
      _task.details = _detailsController.text;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      appBar: AppBar(
        leading: LBackButton(onPressed: () => widget.creatingTask ? Navigator.pop(context) : Navigator.pop(context, _task)),
        title: Text('${widget.creatingTask ? 'Create' : 'Edit'} Task', style: Theme.of(context).textTheme.displayMedium!,),
      ),
      body: ContentContainer(maxWidth: 300.0,child: ListView(
        children: [
          const SizedBox(height: 50.0),
          TextField(
            controller: _nameController,
            style: Theme.of(context).textTheme.displaySmall!,
            decoration: const InputDecoration(
              hintText: 'name'
            ),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: _detailsController,
            style: Theme.of(context).textTheme.displaySmall!,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'details'
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton.icon(
            onPressed: () {
              if (_task.dueDate == null) {
                setState(() {
                  _task.dueDate = DateTime.now();
                });
              } 
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 250.0,
                        child: CupertinoDatePicker(
                          initialDateTime: _task.dueDate,
                          mode: CupertinoDatePickerMode.date,
                          onDateTimeChanged: (date) => setState(() {
                            _task.dueDate = date;
                          }),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(child: SizedBox(
                        width: 200.0,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _task.dueDate = null;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('No date', style: Theme.of(context).textTheme.displaySmall!,)
                        ),
                      )),
                      const SizedBox(height: 50.0,)
                    ],
                  )
                )
              );
            },
            icon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            label: Text(_task.dueDate == null ? 'Pick date' : getDateTimeString(_task.dueDate!), style: Theme.of(context).textTheme.displaySmall!)
          ),
          const SizedBox(height: 20.0),
          RepeatPicker(
            initialValue: _task.repeatFrequency,
            onChanged: (value) {
              _task.repeatFrequency = value;
            }
          ),
          const SizedBox(height: 50.0),
          Center(child: SizedBox(
            width: 200.0,
            child: ElevatedButton(
              onPressed: () {
                if (widget.creatingTask) {
                  Navigator.pop(context, _task);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(widget.creatingTask ? 'Create' : 'Delete task', style: Theme.of(context).textTheme.displaySmall!)
            )
          ))
        ],
      ))
    ));
  }

}