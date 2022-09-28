import 'package:get_it/get_it.dart';

import '../notificationservice/screen/service_location.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  print("setupLocator .... ");
  locator.registerLazySingleton(() => NavigationService());
}