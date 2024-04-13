import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordatorio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderScreen(),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _bodyController = TextEditingController();

    const settingsAndroid = AndroidInitializationSettings('app_icon');
    final settingsIOS = IOSInitializationSettings();
    final settings = InitializationSettings(
      android: settingsAndroid,
      iOS: settingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(settings);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder with Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Cuerpo',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showDateTimePicker();
              },
              child: const Text('Seleccionar Hora'),
            ),
          ],
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
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'high_importance_channel',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool grantedNotificationPermission =
        await androidImplementation?.requestNotificationsPermission() ?? false;

    if (grantedNotificationPermission) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        _titleController.text, // Utilizar el título ingresado por el usuario
        _bodyController.text, // Utilizar el cuerpo ingresado por el usuario
        convertToTZDateTime(selectedTime),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Recordatorio programado para las ${selectedTime.hour}:${selectedTime.minute} horas'),
        ),
      );
    }
  }

  tz.TZDateTime convertToTZDateTime(DateTime dateTime) {
    String timeZoneName = 'America/Mexico_City';
    tz.Location timeZone = tz.getLocation(timeZoneName);
    tz.TZDateTime time = tz.TZDateTime.from(dateTime, timeZone);

    return time;
  }

  IOSInitializationSettings() {}
  IOSNotificationDetails() {}
}
