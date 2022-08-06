import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';

import '../../utils/get_it.dart';
import '../provider/login provider.dart';

class OptScreenWidget extends StatefulWidget {
  const OptScreenWidget({Key? key,}) : super(key: key);

  @override
  _OptScreenWidgetState createState() => _OptScreenWidgetState();
}

class _OptScreenWidgetState extends State<OptScreenWidget> {
  TextEditingController? otpController;
  TextEditingController? textController1;
  final pinTextController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool isLoading = false;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      border: Border.all(color: Colors.white),
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final loginProvider = getIt<LoginProvider>();

  keyboardConfigIos(FocusNode focusNode) {
    return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
        actions: [
          KeyboardActionsItem(
              focusNode: focusNode,
              displayDoneButton: true,
              displayArrows: false)
        ]);
  }

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
    // textController1 = TextEditingController(text: widget.number);
  }

  @override
  Widget build(BuildContext context) {
    double wid = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
          height: height,
          decoration: const BoxDecoration(
            color: Color(0xfff96d34),
            image: DecorationImage(
              image: AssetImage("assets/images/backimage.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                      child: Text('Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                    child: Text('You  will get OTP via  SMS',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: KeyboardActions(
                      disableScroll: true,
                      config: keyboardConfigIos(_pinPutFocusNode),
                      child: PinPut(
                        fieldsCount: 6,
                        controller: pinTextController,
                        enabled: true,
                        textStyle: const TextStyle(fontSize: 25,color: Colors.white),
                        cursorColor: Colors.white,
                        focusNode: _pinPutFocusNode,
                        submittedFieldDecoration: _pinPutDecoration,
                        selectedFieldDecoration: _pinPutDecoration,
                        followingFieldDecoration: _pinPutDecoration,
                        eachFieldHeight: 60.0,
                        eachFieldMargin: const EdgeInsets.all(5.0),
                        onSubmit: (value) async {
                          /*      AuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: widget.verificationId, smsCode: value);
                    var result = await _auth.signInWithCredential(credential);
                    var user = result.user;
                    if (user != null) {
                      isPhoneRegistered(widget.phoneNumber, context);
                    } else {
                      print("Error");
                    }*/
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Consumer<LoginProvider>(builder: (BuildContext context, loginProvider, _) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.only(left: 25.0, right: 25.0),
                        width: wid,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)
                            )
                        ),
                        child: loginProvider.isLoading
                            ? const Center(child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 5)
                        )
                            : MaterialButton(
                              onPressed: () async {
                                if (pinTextController.text.length == 6) {
                                  loginProvider.userPhoneVerify(context,
                                      pinTextController.text);
                                }},
                            child: const Text("CONTINUE", style: TextStyle(fontSize: 25, wordSpacing: 2)),
                            textColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          color: Colors.black38,
                        )
                      )
                    );
                  })
                ],
              ),
            ),
          ),
        ));
  }
}
