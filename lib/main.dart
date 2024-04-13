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
        child: ElevatedButton(
          onPressed: () {
            _showDateTimePicker();
          },
          child: const Text('Seleciona una Hora'),
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
        'Recordatorio',
        'Hora de hacer algo con tu vida!',
        convertToTZDateTime(selectedTime),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Recordatorio programado para las ${selectedTime.hour}:${selectedTime.minute} horas'),
        ),
      );
    }
  }

// Función para convertir DateTime a TZDateTime
  tz.TZDateTime convertToTZDateTime(DateTime dateTime) {
    String timeZoneName = 'America/Mexico_City'; // Ejemplo de zona horaria
    tz.Location timeZone = tz.getLocation(timeZoneName);
    tz.TZDateTime time = tz.TZDateTime.from(dateTime, timeZone);

    return time;
  }

  // ignore: non_constant_identifier_names
  IOSInitializationSettings() {}

  // ignore: non_constant_identifier_names
  IOSNotificationDetails() {}
}
