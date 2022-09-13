import 'package:agora_app/splash_screen.dart';
import 'package:agora_app/utils/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'login/provider/login provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'notificationservice/model/local_notification_service.dart';
import 'notificationservice/screen/recive_call_screen.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}
void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  runApp(const MyApp());
  initialize();

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String deviceTokenToSendPushNotification = "";
  late LoginProvider _loginProvider;
  /*late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;
  final _fcm = FirebaseMessaging.instance;


  void registerNotification() async{
    // await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print(".............. user granted  the permission");
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notificationservice = PushNotification(
            title: message.notificationservice!.title,
            body: message.notificationservice!.body,
            dataTitle: message.data['title'],
            dataBody: message.data['body']
        );
        setState(() {
          _notificationInfo = notificationservice;
        });

        showSimpleNotification(
          Text(_notificationInfo!.title!),
          subtitle: Text(_notificationInfo!.body!),
          background: Colors.cyan.shade400,
          duration: const Duration(seconds: 5),
        );
      });

    }
    else{
      print(".............. permission declined by user ");
    }

  }

  void checkForInitialMessage() async{
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      PushNotification notificationservice = PushNotification(
          title: initialMessage.notificationservice!.title,
          body: initialMessage.notificationservice!.body,
          dataTitle: initialMessage.data['title'],
          dataBody: initialMessage.data['body']
      );
      setState(() {
        _notificationInfo = notificationservice;
      });
      showSimpleNotification(
        Text(initialMessage.notificationservice!.title!),
        subtitle: Text(initialMessage.notificationservice!.body!),
        background: Colors.cyan.shade400,
        duration: const Duration(seconds: 5),
      );
    }
  }*/

  // Future<void> getDeviceTokenToSendNotification() async {
  //   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  //   final token = await _fcm.getToken();
  //   deviceTokenToSendPushNotification = token.toString();
  //   print("Token Value $deviceTokenToSendPushNotification");
  // }
  @override
  void initState() {

    // 1. This method call when app in terminated state and you get a notificationservice
    // when you click on notificationservice app open from terminated state and you can get notificationservice data in this method

    /*FirebaseMessaging.instance.getInitialMessage().then(
          (message) {
           debugPrint("FirebaseMessaging .instance.getInitialMessage");
        if (message != null) {
          debugPrint("New Notification");
          LocalNotificationService.createanddisplaynotification(message);
          if (message.data['_id'] != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RecivedScreen(
                  channel: message.notification!.body![0],
                ),
              ),
            );
          }
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
          (message) {
        print("FirebaseMessaging .onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);

        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
        print("FirebaseMessaging .onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );*/


   /* // when app is background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notificationservice = PushNotification(
          title: message.notificationservice!.title,
          body: message.notificationservice!.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body']
      );
      setState(() {
        _notificationInfo = notificationservice;
      });
      showSimpleNotification(
        Text(_notificationInfo!.title!),
        // leading: const RecivedScreen(),
        subtitle: Text(_notificationInfo!.body!),
        background: Colors.cyan.shade400,
        duration: const Duration(seconds: 5),
      );
    });

    // normal notificationservice
    registerNotification();

    // when app is terminated state
    checkForInitialMessage();
*/
    super.initState();
    _loginProvider = getIt<LoginProvider>();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // getDeviceTokenToSendNotification();
    return OverlaySupport(child: MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=> _loginProvider),
      // ChangeNotifierProvider(create: (_)=> _homeProvider),
    ], child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        // primarySwatch: Colors.blue,
      ),
    )));
  }
}

