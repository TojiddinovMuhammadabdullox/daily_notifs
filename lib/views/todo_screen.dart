import 'package:daily_notifications/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final List<Todo> _todos = [];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _onSelectNotification(String? payload) async {
    // Handle notification tap
  }

  Future<void> _scheduleNotification(
      String title, String body, DateTime scheduledDateTime) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      _convertToTimeZone(scheduledDateTime),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _convertToTimeZone(DateTime scheduledDateTime) {
    var location =
        tz.getLocation('your_timezone'); // Replace with your actual timezone
    // ignore: unused_local_variable
    var now = tz.TZDateTime.now(location);
    var scheduledDate = tz.TZDateTime(
        location,
        scheduledDateTime.year,
        scheduledDateTime.month,
        scheduledDateTime.day,
        scheduledDateTime.hour,
        scheduledDateTime.minute);
    return scheduledDate;
  }

  void _cancelNotification(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  void _cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  void _addTodo() {
    if (_titleController.text.isNotEmpty &&
        _dateTimeController.text.isNotEmpty) {
      setState(() {
        var todo = Todo(
          id: Uuid().v4(),
          title: _titleController.text,
          description: _descriptionController.text,
        );
        _todos.add(todo);
        _titleController.clear();
        _descriptionController.clear();
        _dateTimeController.clear();
      });
    }
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  void _editTodo(String id, String newTitle, String newDescription) {
    setState(() {
      var index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = Todo(
          id: id,
          title: newTitle,
          description: newDescription,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Todo Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Todo Description'),
            ),
            TextField(
              controller: _dateTimeController,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    DateTime combinedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    setState(() {
                      _dateTimeController.text = combinedDateTime.toString();
                    });
                  }
                }
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Due Date & Time',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _addTodo,
                  child: Text('Add Todo'),
                ),
                ElevatedButton(
                  onPressed: () => _cancelAllNotifications(),
                  child: Text('Cancel All Notifications'),
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  var todo = _todos[index];
                  return ListTile(
                    title: Text(todo.title),
                    subtitle: Text(todo.description),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteTodo(todo.id),
                    ),
                    onTap: () {
                      _editTodo(
                        todo.id,
                        'Updated Title',
                        'Updated Description',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
