import 'package:agora_app/notificationservice/screen/service_location.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../utils/locator.dart';

final NavigationService _navigationService = locator<NavigationService>();  // It is assumed that all messages contain a data field with the key 'type'
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PushNotificationService {

  Future<void> setupInteractedMessage({context}) async {
    await Firebase.initializeApp();
    print("mathod called .....");
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // LocalNotificationService.createanddisplaynotification(message);
      print("onMessageOpenedApp");
      _navigationService.navigateTo("/recivedScreen",message.notification!.body, message.data.values.last, message.data.values.last=="Audience"? ClientRole.Audience : ClientRole.Broadcaster, message.data.values.first,);
      // navigatorKey.currentState!.pushNamed('/recivedScreen',arguments: message);
        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //   builder: (context) => RecivedScreen(
        //     channel: message.notification!.body,
        //     type: message.data.values.last,
        //     clientRole:message.data.values.last=="Audience"? ClientRole.Audience : ClientRole.Broadcaster,
        //     name: message.data.values.first,
        //   ),
        // ));
    });
    await enableIOSNotifications();
    await registerNotificationListeners(context);
  }
  registerNotificationListeners(context) async {
    print("Called method1");
    AndroidNotificationChannel channel = androidNotificationChannel();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    var androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSSettings = const IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    var initSetttings = InitializationSettings(android: androidSettings, iOS: iOSSettings);

    flutterLocalNotificationsPlugin.initialize(initSetttings, onSelectNotification: (message) async {});

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      _navigationService.navigateTo("/recivedScreen",message!.notification!.body, message.data.values.last, message.data.values.last=="Audience"? ClientRole.Audience : ClientRole.Broadcaster, message.data.values.first,);

      // Get.find<HomeController>().getNotificationsNumber();
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
// If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              "pushnotificationapp",
              "pushnotificationappchannel",
              importance: Importance.max,
              // priority: Priority.high,
              playSound: true,
              enableVibration: true,
              visibility: NotificationVisibility.public,
              showWhen: true
            ),
          ),
        );
        print("onMessage");
        print("navigateTo call");
        // navigatorKey.currentState!.pushNamed('/recivedScreen',arguments: message);
        // _navigationService.navigateTo('/recivedScreen',message);
        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //   builder: (context) => RecivedScreen(
        //     channel: message.notification!.body,
        //     type: message.data.values.last,
        //     clientRole:message.data.values.last=="Audience"? ClientRole.Audience : ClientRole.Broadcaster,
        //     name: message.data.values.first,
        //   ),
        // ));
      }
    });
  }
  enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }
  androidNotificationChannel() => const AndroidNotificationChannel(
    'pushnotificationapp', // id
    'pushnotificationappchannel', // title
    importance: Importance.max,
  );
}