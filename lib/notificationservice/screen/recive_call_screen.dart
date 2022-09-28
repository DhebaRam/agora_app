import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:clear_all_notifications/clear_all_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../home/screen/audio_call_screen.dart';
import '../../home/screen/home_screen.dart';
import '../../utils/app&token_id.dart';

class RecivedScreen extends StatefulWidget {
  final String? channel;
  final String? type;
  final ClientRole? clientRole;
  final String? name;

  const RecivedScreen({Key? key, required this.channel, required this.type,required this.clientRole,required this.name}) : super(key: key);

  @override
  State<RecivedScreen> createState() => RecivedScreenState();
}

class RecivedScreenState extends State<RecivedScreen> {
  void onNotReciverEnd(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>const HomeScreen()));
  }
  Future<void> initClearNotificationsState() async {
    ClearAllNotifications.clear();
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("recive Screen .......");
    initClearNotificationsState();
  }
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 30), () {
        onNotReciverEnd(context);
    });
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  !isLandscape ? const SizedBox(height: 100) : Container(),
                  widget.type == "voice" ? const Icon(Icons.account_circle, size: 120) : Container(),
                  Center(child: Text("${widget.name}")),
                  !isLandscape ? const SizedBox(height: 10) : Container(),
                  Center(child: Text("${widget.channel}")),
                  !isLandscape ? const Expanded(child: SizedBox(height: 50)) : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      RawMaterialButton(
                        onPressed: () => _onCallEnd(context),
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 35.0,
                        ),
                        shape: const CircleBorder(),
                        elevation: 2.0,
                        fillColor: Colors.redAccent,
                        padding: const EdgeInsets.all(15.0),
                      ),
                      const SizedBox(width: 100),
                      RawMaterialButton(
                        onPressed: () => _onCallRecived(context),
                        child: const Icon(
                          Icons.call,
                          color: Colors.white,
                          size: 35.0,
                        ),
                        shape: const CircleBorder(),
                        elevation: 2.0,
                        fillColor: Colors.green,
                        padding: const EdgeInsets.all(15.0),
                      ),
                    ],
                  ),
                  !isLandscape ? const SizedBox(height: 100) : Container(),

                ],
              ),
            )));
  }

  SvgPicture image() {
    Future.delayed(const Duration(seconds: 2), () {
    });
    return SvgPicture.asset("assets/images/wave8.svg", fit: BoxFit.fill);
  }

  void _onCallEnd(BuildContext context) {
    initClearNotificationsState();
    // Navigator.pop(context);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
  void _onCallRecived(BuildContext context) {
    // Navigator.pop(context);
    initClearNotificationsState();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AudioCallScreen(clientRole: widget.clientRole,name: widget.name ,callType: widget.type, number: widget.channel,channelName: channel)),(Route<dynamic> route) => false);
  }
}

class ScreenArguments {
  final String channel;
  final String type;
  final ClientRole clientRole;
  final String name;

  ScreenArguments(this.channel, this.type, this.clientRole, this.name);
}