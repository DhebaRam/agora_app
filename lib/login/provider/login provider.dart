import 'dart:convert';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../home/screen/home_screen.dart';
import '../../utils/app_utils.dart';
import '../screen/otp_screen.dart';

class LoginProvider extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String verificationId = "";
  String currentUserId = "";
  bool isLoading = false;
  String userName = "";
  bool groupNumber = false;
  List deviceTokenToSendPushNotification = [];

  userPhoneLogin(BuildContext context,phoneNo) async{
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("number", phoneNo);
    try {
      FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNo,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential).then((value) {
              debugPrint("You are logged successfully");
              isLoading = false;
              notifyListeners();
            });
          },
          verificationFailed: (FirebaseAuthException exception) {
            debugPrint(exception.message);
            if (exception.code == 'invalid-phone-number') {
              isLoading = false;
              AppUtils.instance.showToast(toastMessage: "Phone provided phone number is not valid.");
              notifyListeners();
            }
          },
          codeSent: (String verificationID, int? resendToken) {
            verificationId = verificationID;
            isLoading = false;
            notifyListeners();
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const OptScreenWidget()));
          },
          timeout: const Duration(seconds: 90),
          codeAutoRetrievalTimeout: (String verificationID) {
            isLoading = false;
          });
    } catch (e) {
      isLoading = false;
      debugPrint("catch block......................");
      notifyListeners();
    }
    notifyListeners();
  }

  userPhoneVerify(BuildContext context,value)async{
    isLoading = true;
    notifyListeners();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: value.toString());
    await auth.signInWithCredential(credential).then((value) async {
      getCurrentUserAuthId();
      // getDeviceTokenToSendNotification();
      userDetailsData();
      debugPrint("You are logged in successfully");
      setValue();
      isLoading = false;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeScreen()), (Route<dynamic> route) => false);
    }).catchError((error) {
      isLoading = false;
      notifyListeners();
      AppUtils.instance.showToast(toastMessage: "Invalid OTP !");
      debugPrint("4error $error");
    });
  }
  getCurrentUserAuthId(){
    final user = auth.currentUser;
    currentUserId = user!.uid;
  }
  userDetailsData()async{
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    print("Token Value2 $token");
    deviceTokenToSendPushNotification.add(token);
    print("Token Value2 $deviceTokenToSendPushNotification");
    final prefs = await SharedPreferences.getInstance();
    List phoneNo=[];// = prefs.getString("number");
    phoneNo.add(prefs.getString("number"));
    print("phone No $phoneNo");
    Map<String, dynamic> userDetails = {"auth_id": currentUserId, "phone_No": phoneNo, 'user_name': userName, 'deviceNotificationToken':deviceTokenToSendPushNotification, 'timestamp': DateTime.now(),"bool":false, "group":false};
    await firestore.collection("use_details").doc(phoneNo.join()).set(userDetails);
  }
  createGroupDetails(List number, Map<String, dynamic> userDetails,BuildContext context) async{
    await firestore.collection("use_details").doc().set(userDetails).then((value) => Navigator.pop(context)); //number.join().toString()
  }
  void setValue() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("login", true);
  }

  audioCallNotification(notificationToken, userName, phoneNumber, currentName, callType,call) async{
    debugPrint("Method called $notificationToken");
    debugPrint("Method called $userName");
    debugPrint("Method called $phoneNumber");
    debugPrint("Method called $currentName");
    debugPrint("Method called $callType");
    final msg = jsonEncode({
      "registration_ids": <String>[
        "$notificationToken"
      ],
      "notification": {
        "title": "$currentName $call",
        "body": "$phoneNumber",
        // "priority": "high",
        "android_channel_id": "pushnotificationapp",
        "sound": true,
      },
      "data":{
        "type":"$callType",
        "name":"$currentName",
      }
    });

    try {
      var response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Authorization': 'key=AAAA6PwCfB8:APA91bExAx4JwP-aPn4zgveZVzoIZeIj5bRoflam8ywiOP7Gc_Gf8BG8ee9G8gzDgASi-_S0Y2zAU7dPp8HnYT-k5PLXni0D5cTln4fbUl0t2LJOXSpBOiNofAqFKnaaT4Bgi5f4XCkM',
            'Content-Type': 'application/json'
          },
          body: msg,
      );

      if(response.statusCode==200){
        debugPrint("Notification Send");
      }else{
        debugPrint("Notification Send Error");
      }
    }catch(e){
      debugPrint("Debug print Catch $e");
    }

  }

  checkGroupMobileNumber(param0){
    if(groupNumber){
      groupNumber = false;
      notifyListeners();
    }

    for(var i in param0) {
      if (i == auth.currentUser!.phoneNumber) {
        if(groupNumber==false){
          groupNumber = true;
          notifyListeners();
        }
        // groupNumber = true;
        // notifyListeners();
      }
    }
    // notifyListeners();
  }
  // Future<void> getDeviceTokenToSendNotification() async {
  //   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  //   final token = await _fcm.getToken();
  //   deviceTokenToSendPushNotification = token.toString();
  //   print("Token Value1 $deviceTokenToSendPushNotification");
  // }
}