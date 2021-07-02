import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {
  static void send(String title, String payload) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = new AndroidInitializationSettings('@drawable/ic_stat_a');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);

    Future.delayed(Duration(seconds: 0)).then((result) async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails('ARRIVE ID', 'Arrive notifications', 'Notifications about starting/stopping geofencing service',
          importance: Importance.Low, priority: Priority.Low, ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(new Random().nextInt(100), title, payload, platformChannelSpecifics, payload: 'item x');
    });
  }
}
