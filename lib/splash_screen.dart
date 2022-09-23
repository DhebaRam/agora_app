import 'dart:async';
import 'package:agora_app/utils/app_images.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'animation_screen/fade_animation.dart';
import 'home/screen/home_screen.dart';
import 'login/screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  check() {
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey("login")) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      debugPrint("completed");
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 3), () {
      check();
    });

  }

  @override
  Widget build(BuildContext context) {
    double wid = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
              height: height,
              width: wid,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/backimage.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  image(),
                  const Positioned(
                    top: 100,
                    left: 45,
                    child: FadeAnimation(2,
                      Text("Agora",
                        style: TextStyle(
                            color: Colors.white, fontSize: 50,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontFamily: "Lobster"),
                      ),
                    ),
                  )
                ],
              ),
            )));
  }

  SvgPicture image() {
    Future.delayed(const Duration(seconds: 2), () {
    });

    return SvgPicture.asset(AppImage.wave/*"assets/images/wave8.svg"*/, fit: BoxFit.fill);

  }
}
