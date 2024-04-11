import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder with Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ReminderScreen(),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    const settingsAndroid = AndroidInitializationSettings('app_icon');
    final settingsIOS = IOSInitializationSettings();
    final settings = InitializationSettings(
      android: settingsAndroid,
      iOS: settingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder with Notifications'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            _showDateTimePicker();
          },
          child: const Text('Select Reminder Time'),
        ),
      ),
    );
  }

  void _showDateTimePicker() {
    DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      onChanged: (time) {},
      onConfirm: (time) {
        _scheduleNotification(time);
      },
      currentTime: DateTime.now(),
    );
  }

  void _scheduleNotification(DateTime selectedTime) async {
    var androidPlatformChannelSpecifics =  const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      'Time to do something!',
      _nextInstanceOfSelectedTime(selectedTime),
      platformChannelSpecifics,
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder scheduled at ${selectedTime.hour}:${selectedTime.minute}'),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfSelectedTime(DateTime selectedTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
  
  // ignore: non_constant_identifier_names
  IOSInitializationSettings() {}
  
  // ignore: non_constant_identifier_names
  RaisedButton({required Null Function() onPressed, required Text child}) {}
  
  // ignore: non_constant_identifier_names
  IOSNotificationDetails() {}
}