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
  String deviceTokenToSendPushNotification = "";

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
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
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
    deviceTokenToSendPushNotification = token.toString();
    print("Token Value2 $deviceTokenToSendPushNotification");
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString("number");
    Map<String, dynamic> userDetails = {"auth_id": currentUserId, "phone_No": number, 'user_name': userName, 'deviceNotificationToken':deviceTokenToSendPushNotification, 'timestamp': DateTime.now(),"bool":false, "group":false};
    await firestore.collection("use_details").doc(number).set(userDetails);
  }
  createGroupDetails(List number, Map<String, dynamic> userDetails,BuildContext context) async{
    await firestore.collection("use_details").doc(number.join().toString()).set(userDetails).then((value) => Navigator.pop(context));
  }
  void setValue() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("login", true);
  }

  audioCallNotification(notificationToken, userName, phoneNumber, currentName, callType) async{
    debugPrint("Method called");
    final msg = jsonEncode({
      "registration_ids": <String>[
        "$notificationToken"
      ],
      "notification": {
        "title": "$userName Coming Call",
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
            'Authorization': 'key=AAAAKUAk4oU:APA91bGvpp8EFdMFmHtS8qNsDQFnre7h_wJ1bKCBNDZTitJbwjt8zPblaFnZW4PVgy155COyr1nUFa6txLAwvWSEn4H2bgTnDIW63OZa6rK2CgkwRUCmIQrtdmyVJS9qXZ6T6JPyfgrj',
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
  // Future<void> getDeviceTokenToSendNotification() async {
  //   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  //   final token = await _fcm.getToken();
  //   deviceTokenToSendPushNotification = token.toString();
  //   print("Token Value1 $deviceTokenToSendPushNotification");
  // }
}