import 'package:get_it/get_it.dart';

import '../login/provider/login provider.dart';

final getIt = GetIt.instance;
// final getIt=GetIt.instance;

initialize(){
  getIt.registerSingleton(LoginProvider());
  // getIt.registerSingleton(HomeProvider());
}