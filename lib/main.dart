import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationTestScreen(flutterLocalNotificationsPlugin),
    );
  }
}

class NotificationTestScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationTestScreen(this.flutterLocalNotificationsPlugin);

  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await widget.flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          debugPrint('Notification payload: ${notificationResponse.payload}');
        }
      },
    );
  }

  Future<void> _showNotification() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // Replace with your channel id
      'your_channel_name', // Replace with your channel name
      description: 'your_channel_description', // Replace with your channel description
      importance: Importance.max,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id', // Must match channel.id
        'your_channel_name', // Must match channel.name
        channelDescription: 'your_channel_description', // Must match channel.description
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      ),
    );

    await widget.flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification',
      notificationDetails,
      payload: 'item x',
    );
  }

  Future<void> _scheduleNotification() async {
    tz.initializeTimeZones();

    // Get the current time and date
    final now = DateTime.now();

    // Set the scheduled time to 1 PM
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      13, // 1 PM (24-hour format)
      0,  // Minute
    );

    // If 1 PM has already passed today, schedule for tomorrow
    final scheduledDate = scheduledDateTime.isBefore(now)
        ? tz.TZDateTime.from(scheduledDateTime.add(Duration(days: 1)), tz.local)
        : tz.TZDateTime.from(scheduledDateTime, tz.local);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id',
      'your_channel_name',
      description: 'your_channel_description',
      importance: Importance.max,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      ),
    );

    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Scheduled Notification',
      'This notification is scheduled for 1 PM',
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Test App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showNotification,
              child: Text('Show Notification'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: Text('Schedule Notification at 1 PM'),
            ),
          ],
        ),
      ),
    );
  }
}
