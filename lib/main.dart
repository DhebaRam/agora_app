import 'package:agora_app/notificationservice/screen/service_location.dart';
import 'package:agora_app/splash_screen.dart';
import 'package:agora_app/utils/get_it.dart';
import 'package:agora_app/utils/locator.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login/provider/login provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notificationservice/screen/local_notification_service.dart';
import 'notificationservice/screen/push_notification_service.dart';
import 'notificationservice/screen/recive_call_screen.dart';

final NavigationService _navigationService = locator<NavigationService>();  // It is assumed that all messages contain a data field with the key 'type'

Future<void> backgroundHandler(RemoteMessage message) async {
  // Firebase.initializeApp();
  // LocalNotificationService.createanddisplaynotification(message);
  debugPrint("Message background ${message.data.toString()}");
  debugPrint(message.notification!.title);
  /*await Firebase.initializeApp();
  // FirebaseMessaging.instance.getInitialMessage().then(
  //         (message) {

        debugPrint("FirebaseMessaging .instance.getInitialMessage.........");
        // LocalNotificationService.createanddisplaynotification(message);
        if (message.notification != null) {
          print("Notification Id if ....");
          print("Notification Id if ....${message.notification!.body}");
          _navigationService.navigateTo("/recivedScreen",message.notification!.body, message.data.values.last, message.data.values.last=="Audience"? ClientRole.Audience : ClientRole.Broadcaster, message.data.values.first,);

          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(
          //     builder: (context) => RecivedScreen(
          //       channel: message.notification!.body,
          //       type: message.data.values.last,
          //       clientRole:message.data.values.last=="Audience" ? ClientRole.Audience : ClientRole.Broadcaster,
          //       name: message.data.values.first,
          //     ),
          //   ),
          // );
        // }
      }
  // );*/
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  await PushNotificationService().setupInteractedMessage();
  setupLocator();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(const MyApp());
  initialize();
  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    _navigationService.navigateTo("/recivedScreen",message.notification!.body, message.data.values.last, message.data.values.last=="Audience"? ClientRole.Audience : ClientRole.Broadcaster, message.data.values.first,);
    // App received a notification when it was killed
  }

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late LoginProvider _loginProvider;

  @override
  void initState() {
    super.initState();
    _loginProvider = getIt<LoginProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=> _loginProvider),
      // ChangeNotifierProvider(create: (_)=> _homeProvider),
    ], child: MaterialApp(
      // routes: {
      //   '/recivedScreen': (context) => const RecivedScreen(),
      // },
      navigatorKey: locator<NavigationService>().navigatorKey,

      onGenerateRoute: (settings) {
        if (settings.name == '/recivedScreen') {
          final args = settings.arguments as ScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return RecivedScreen( channel: args.channel,type: args.type, clientRole: args.clientRole, name: args.name, );
            },
          );
        }

        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      theme: ThemeData(
      ),
    ));
  }
}

