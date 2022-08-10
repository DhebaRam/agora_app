import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          codeAutoRetrievalTimeout: (String verificationID) {});
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
    final prefs = await SharedPreferences.getInstance();
    String? number = prefs.getString("number");
    Map<String, dynamic> userDetails = {"auth_id": currentUserId, "phone_No": number, 'user_name': userName, 'timestamp': DateTime.now()};
    await firestore.collection("use_details").doc(number).set(userDetails);
  }
  void setValue() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("login", true);
  }
}