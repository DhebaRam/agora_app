import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService{

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize() {
    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: IOSInitializationSettings(requestAlertPermission: true,requestBadgePermission: true,requestSoundPermission: true,defaultPresentAlert: true,defaultPresentBadge: true,defaultPresentSound: true)
    );


    _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? id) async {
        print("onSelectNotification");
      },
    );
  }

  static void createanddisplaynotification(RemoteMessage message) async {
    print("Back Groud Call....");
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetailsAndroid = NotificationDetails(
        android: AndroidNotificationDetails(
          "pushnotificationapp",
          "pushnotificationappchannel",
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(presentAlert: true,presentSound: true,presentBadge: true,threadIdentifier: "pushnotificationapp",subtitle: "pushnotificationappchannel"),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body!,
        notificationDetailsAndroid,
        // payload: message.data['_id'],
      );
      print(".........");
    } on Exception catch (e) {
      print("catch block $e");
    }
  }
  }