import 'package:agora_app/splash_screen.dart';
import 'package:agora_app/utils/get_it.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login/provider/login provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  initialize();

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late LoginProvider _loginProvider;
  // late HomeProvider _homeProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loginProvider = getIt<LoginProvider>();
    // _homeProvider = getIt<HomeProvider>();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
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
    ));
  }
}

