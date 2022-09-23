import 'package:agora_app/splash_screen.dart';
import 'package:agora_app/utils/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login/provider/login provider.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'notificationservice/model/local_notification_service.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  debugPrint("Message background ${message.data.toString()}");
  debugPrint(message.notification!.title);
}
void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  // LocalNotificationService.initialize();
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
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      theme: ThemeData(
      ),
    ));
  }
}

