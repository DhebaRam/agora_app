import 'package:agora_app/notificationservice/screen/recive_call_screen.dart';
import 'package:agora_rtc_engine/src/enums.dart';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, String? channel, type, ClientRole clientRole, name) {
    print("NavigationService 111....");
    return navigatorKey.currentState!.pushNamed(routeName,arguments: ScreenArguments(channel!,type,clientRole,name,));
    /*,{"Channel":channel,"Type":type,"ClientRole":clientRole,"Name":name})*/
  }


  /*final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Future<dynamic> navigateTo(String routeName, RemoteMessage message) {
    print("meaasheee ${message.notification!.title}");
    print("meaasheee ${routeName}");
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  void setupLocator() {
    locator.registerLazySingleton(() => NavigationService());
  }*/
}


// class Locator{
//   void setupLocator() {
//     locator.registerLazySingleton(() => NavigationService());
//   }
//
// }