import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login/provider/login provider.dart';
import '../../login/screen/login_screen.dart';
import '../../utils/app&token_id.dart';
import '../../utils/app_colors.dart';
import '../../utils/get_it.dart';
import 'audio_call_screen.dart';
import 'create_group_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List listContactList = [];
  List currentUser = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final loginProvider = getIt<LoginProvider>();
  bool checkGroupUser = false;
  StreamSubscription? connection;
  bool isoffline = false;

  @override
  void initState() {
    _handleCameraAndMic(Permission.camera);
    _handleCameraAndMic(Permission.microphone);
    // TODO: implement initState
    super.initState();
  }
  Future<void> _handleCameraAndMic(Permission permission) async {
    await permission.request();
  }
  void checkInternet(){
    connection = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // whenevery connection status is changed.
      if(result == ConnectivityResult.none){
        //there is no any connection
        setState(() {
          isoffline = true;
        });
      }else if(result == ConnectivityResult.mobile){
        //connection is mobile data network
        setState(() {
          isoffline = false;
        });
      }else if(result == ConnectivityResult.wifi){
        //connection is from wifi
        setState(() {
          isoffline = false;
        });
      }else if(result == ConnectivityResult.ethernet){
        //connection is from wired connection
        setState(() {
          isoffline = false;
        });
      }else if(result == ConnectivityResult.bluetooth){
        //connection is from bluetooth threatening
        setState(() {
          isoffline = false;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    checkInternet();
    double wid = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return WillPopScope(
      onWillPop: () => willPop(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            iconTheme: const IconThemeData(
              color: Colors.indigoAccent, //change your color here
            )
            ,title: Row(
          children: [
            const Expanded(child: Text("Contacts")),
            IconButton(onPressed: () async{
              return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: AppColor.appColor,
                      content: const Text(
                        "Are you sure you want to logout?", textAlign: TextAlign.center,),
                      actions: [
                        MaterialButton(
                          color: AppColor.blue,
                          child: const Text('Yes'),
                          onPressed: () async{
                            FirebaseAuth.instance.signOut();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            await firestore.collection('use_details').doc(auth.currentUser!.phoneNumber).delete();
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
                          },
                        ),
                        MaterialButton(
                          color: AppColor.blue,
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  });
            }, icon: const Icon(Icons.power_settings_new,color: AppColor.white,))
          ],
        ),backgroundColor: Colors.indigoAccent),
        body: Container(
          height: height,
          decoration: const BoxDecoration(
            color: Color(0xfff96d34),
            image: DecorationImage(
              image: AssetImage("assets/images/backimage.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: isoffline ? SizedBox(
            height: height,
            width: wid,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                //Here I am using an svg icon
                Icon(Icons.signal_wifi_statusbar_connected_no_internet_4,size: 280),
                // Image.asset("assets/images/checkInternet.png",
                //   width: 200,
                //   height: 200,
                // ),
                SizedBox(height: 50),
                Text(
                  'Internet connection lost!',
                  style: TextStyle(fontSize: 19, color: AppColor.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Check your connection and try again.',
                  style: TextStyle(fontSize: 16, color: AppColor.white),
                )
              ],
            ),
          ) : Column(
            children: [
              isoffline ? Container(
                width: double.infinity,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom:5),
                color: isoffline?Colors.red:Colors.lightGreen,
                //red color on offline, green on online
                padding:const EdgeInsets.all(10),
                child: Text(isoffline?"Device is Offline":"Device is Online",
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white
                  ),),
              ) : const Text(""),
              Padding(padding: const EdgeInsets.only(left: 18.0,right: 18.0,top: 5),
                child: GestureDetector(
                  onTap: () {
                    currentUser.clear();
                    listContactList.clear();
                    Stream<QuerySnapshot<Map<String, dynamic>>> userData = firestore.collection('use_details').where("group",isEqualTo: false).snapshots();
                    Stream<QuerySnapshot<Map<String, dynamic>>> currentUserData = firestore.collection('use_details').where("auth_id", isEqualTo: auth.currentUser!.uid).snapshots();
                    userData.map((event) => event.docs.map((e) => listContactList.add(e.data())).toList()).toList();
                    currentUserData.map((event) => event.docs.map((e) => currentUser.add(e.data())).toList()).toList();
                    Navigator.push(context,MaterialPageRoute(builder: (context)=> CreateGroupScreen(listContactList,currentUser)));

                  },
                  child: Card(
                      child: Row(
                        children: [
                          Padding(
                              padding: isLandscape ? const EdgeInsets.only(left: 70,top: 5,bottom: 5) : const EdgeInsets.only(left: 15,bottom: 5,top: 5),
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(100)),
                                  child: const Icon(Icons.group,
                                      color: AppColor.white, size: 30))
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Text("New Group",style: TextStyle(fontWeight: FontWeight.bold),)
                            ),
                          ),
                        ],
                      ))
                )),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(                                                //orderBy("timestamp",descending: true)
                    stream: firestore.collection('use_details').where("auth_id", isNotEqualTo: auth.currentUser!.uid).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColor.blue,));
                      if(snapshot.data!.size ==0) return const Center(child: Text("No User found.."),);
                      if(snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context,index) {
                              Timestamp timestampTime = snapshot.data!.docs[index].get("timestamp");
                              DateTime date = timestampTime.toDate();
                              String datetime =  date.day.toString() +"/"+ date.month.toString() +"/"+ date.year.toString();
                              // if(auth.currentUser!.phoneNumber == snapshot.data!.docs[index].get("phone_No").map((e)=>e["phone_No"])){
                              //   snapshot.data!.docs[index].get("phone_No").map((e)=>debugPrint(e["phone_No"]));
                              // if(snapshot.data!.docs[index].get("group")) {
                              //   debugPrint(snapshot.data!.docs[index].get("phone_No").map((e)=>e).toList());
                              // }
                              // }
                              Provider.of<LoginProvider>(context,listen: false).checkGroupMobileNumber(snapshot.data!.docs[index].get("phone_No"));
                              if(snapshot.data!.docs[index].get("group") == true && Provider.of<LoginProvider>(context,listen: false).groupNumber){
                                // debugPrint("1111... ${snapshot.data!.docs[index].get("group") == true && Provider.of<LoginProvider>(context,listen: false).groupNumber}");
                                // debugPrint("1111...11 ${Provider.of<LoginProvider>(context,listen: false).groupNumber}");
                                // Provider.of<LoginProvider>(context,listen: false).checkGroupMobileNumber(snapshot.data!.docs[index].get("phone_No"));
                                // DocumentSnapshot x = snapshot.data!.docChanges[index].doc;
                                // for(var i in snapshot.data!.docs[index].get("phone_No")) {
                                //   if(i == auth.currentUser!.phoneNumber){
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 18.0, right: 18.0, top: 5),
                                      child: GestureDetector(
                                        child: Card(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                  padding: isLandscape
                                                      ? const EdgeInsets.only(
                                                      left: 70)
                                                      : const EdgeInsets.only(
                                                      left: 15),
                                                  child: Container(
                                                      alignment: Alignment.center,
                                                      padding: const EdgeInsets.all(
                                                          5),
                                                      decoration: BoxDecoration(
                                                          color: AppColor.blue,
                                                          borderRadius: BorderRadius
                                                              .circular(100)),
                                                      child: snapshot.data!
                                                          .docs[index].get(
                                                          "group") == true ? const Icon(
                                                          Icons.group,
                                                          color: AppColor.white,
                                                          size: 30) : const Icon(
                                                          Icons.person,
                                                          color: AppColor.white,
                                                          size: 30))
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 15),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text("${snapshot.data!.docs[index].get("user_name")}",
                                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColor.blue),),
                                                      Text(datetime.toString(), style: const TextStyle(color: AppColor.blue),),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              snapshot.data!.docs[index].get("group") != true ?
                                              IconButton(
                                                  icon: const Icon(
                                                  Icons.phone_outlined,
                                                  color: Colors.black, size: 30),
                                                  onPressed: () async {
                                                    CollectionReference collection = firestore.collection('use_details');
                                                    QuerySnapshot querySnapshots = await collection.where("auth_id", isEqualTo: auth.currentUser!.uid).get();
                                                    dynamic name = querySnapshots.docs.map((e) => e.get("user_name")).toList();

                                                    DocumentSnapshot x = snapshot.data!.docChanges[index].doc;
                                                    x.reference.snapshots().map((e) {
                                                      for (int i = 0; i < e.get("phone_No").length; i++) {
                                                        if (e.get("auth_id")[i] != auth.currentUser!.uid) {
                                                          debugPrint("deviceNotificationToken ${e.get("deviceNotificationToken")[i]}");
                                                          debugPrint("deviceNotificationToken ${auth.currentUser!.uid}");
                                                          loginProvider.audioCallNotification(snapshot.data!.docs[index].get("deviceNotificationToken")[i],
                                                              snapshot.data!.docs[index].get("user_name"),
                                                              snapshot.data!.docs[index].get("phone_No")[i], name.join(), "voice","Voice Call");
                                                        }
                                                        // debugPrint("22211 ${e.get("phone_No")[i]}");
                                                      }
                                                    }).toList();
                                                    // loginProvider.audioCallNotification(snapshot.data!.docs[index].get("deviceNotificationToken"),snapshot.data!.docs[index].get("user_name"),snapshot.data!.docs[index].get("phone_No"),name.join(),"voice");
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AudioCallScreen(
                                                                    clientRole: ClientRole.Broadcaster,
                                                                    name: snapshot.data!.docs[index].get("user_name"),
                                                                    callType: "voice",
                                                                    number: snapshot.data!.docs[index].get("phone_No").first, channelName: channel)));
                                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => IndexPage()));
                                                  }) : const SizedBox.shrink(),
                                              const SizedBox(width: 15),
                                              IconButton(
                                                  icon: const Icon(
                                                  Icons.video_call_outlined,
                                                  color: Colors.black, size: 30),
                                                  onPressed: () async {
                                                    CollectionReference collection = firestore.collection('use_details');
                                                    QuerySnapshot querySnapshots = await collection.where("auth_id",
                                                        isEqualTo: auth.currentUser!.uid).get();
                                                    dynamic name = querySnapshots.docs.map((e) => e.get("user_name")).toList();

                                                    DocumentSnapshot x = snapshot.data!.docChanges[index].doc;
                                                    x.reference.snapshots().map((e) {
                                                      for (int i = 0; i < e.get("phone_No").length; i++) {
                                                        if (e.get("auth_id")[i] != auth.currentUser!.uid) {
                                                          debugPrint("deviceNotificationToken ${e.get("deviceNotificationToken")[i]}");
                                                          debugPrint("deviceNotificationToken ${auth.currentUser!.uid}");
                                                          loginProvider.audioCallNotification(
                                                              snapshot.data!.docs[index].get("deviceNotificationToken")[i],
                                                              snapshot.data!.docs[index].get("user_name"),
                                                              snapshot.data!.docs[index].get("phone_No")[i], name.join(), "video","Video Call");
                                                        }
                                                      }
                                                    }).toList();
                                                    // loginProvider.audioCallNotification(snapshot.data!.docs[index].get("deviceNotificationToken"),snapshot.data!.docs[index].get("user_name"),snapshot.data!.docs[index].get("phone_No"),name.join(),"video");
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AudioCallScreen(
                                                                    clientRole: ClientRole.Broadcaster,
                                                                    name: snapshot.data!.docs[index].get("user_name"),
                                                                    callType: "video",
                                                                    number: snapshot.data!.docs[index].get("phone_No").first,
                                                                    channelName: channel)));
                                                  }),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                      ),
                                      ),
                                    );
                              }else if(snapshot.data!.docs[index].get("group") == false){
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0, right: 18.0, top: 5),
                                  child: GestureDetector(
                                    child: Card(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) => //LiveScreen(channelName: channel,)));
                                                      const AudioCallScreen(
                                                          clientRole: ClientRole.Audience,
                                                          name: "",
                                                          callType: "Audience", //"Audience",
                                                          number: "",
                                                          channelName: channel)));
                                            },
                                            child: Padding(
                                                padding: isLandscape
                                                    ? const EdgeInsets.only(
                                                    left: 70)
                                                    : const EdgeInsets.only(
                                                    left: 15),
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets.all(
                                                        5),
                                                    decoration: BoxDecoration(
                                                        color: AppColor.blue, borderRadius: BorderRadius
                                                        .circular(100)),
                                                    child: snapshot.data!.docs[index].get("group") == true ? const Icon(
                                                        Icons.group, color: AppColor.white, size: 30) : const Icon(Icons.person,
                                                        color: AppColor.white, size: 30))
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 15),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text("${snapshot.data!.docs[index].get("user_name")}",
                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColor.blue),),
                                                  Text(datetime.toString(),
                                                    style: const TextStyle(color: AppColor.blue),),
                                                ],
                                              ),
                                            ),
                                          ),
                                          snapshot.data!.docs[index].get("group") != true ?
                                          IconButton(
                                              icon: const Icon(
                                              Icons.phone_outlined,
                                              color: Colors.black, size: 30),
                                              onPressed: () async {
                                                CollectionReference collection = firestore.collection('use_details');
                                                QuerySnapshot querySnapshots = await collection.where("auth_id", isEqualTo: auth.currentUser!.uid).get();
                                                dynamic name = querySnapshots.docs.map((e) => e.get("user_name")).toList();

                                                DocumentSnapshot x = snapshot.data!.docChanges[index].doc;
                                                x.reference.snapshots().map((e) {
                                                  for (int i = 0; i < e.get("phone_No").length; i++) {
                                                    if (e.get("auth_id")[i] != auth.currentUser!.uid) {
                                                      debugPrint("deviceNotificationToken ${e.get("deviceNotificationToken")[i]}");
                                                      debugPrint("deviceNotificationToken ${auth.currentUser!.uid}");
                                                      loginProvider.audioCallNotification(snapshot.data!.docs[index].get("deviceNotificationToken")[i],
                                                          snapshot.data!.docs[index].get("user_name"),
                                                          snapshot.data!.docs[index].get("phone_No")[i], name.join(), "voice","Voice Call");
                                                    }
                                                    // debugPrint("22211 ${e.get("phone_No")[i]}");
                                                  }
                                                }).toList();
                                                // loginProvider.audioCallNotification(snapshot.data!.docs[index].get("deviceNotificationToken"),snapshot.data!.docs[index].get("user_name"),snapshot.data!.docs[index].get("phone_No"),name.join(),"voice");
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AudioCallScreen(clientRole: ClientRole.Broadcaster, name: snapshot.data!.docs[index].get("user_name"),
                                                                callType: "voice",
                                                                number: snapshot.data!.docs[index].get("phone_No").first, channelName: channel)));
                                                // Navigator.push(context, MaterialPageRoute(builder: (context) => IndexPage()));
                                              }) : const SizedBox.shrink(),
                                          const SizedBox(width: 15),
                                          IconButton(
                                              icon: const Icon(
                                              Icons.video_call_outlined,
                                              color: Colors.black, size: 30),
                                              onPressed: () async {
                                                CollectionReference collection = firestore.collection('use_details');
                                                QuerySnapshot querySnapshots = await collection.where("auth_id", isEqualTo: auth.currentUser!.uid).get();
                                                dynamic name = querySnapshots.docs.map((e) => e.get("user_name")).toList();

                                                DocumentSnapshot x = snapshot.data!.docChanges[index].doc;
                                                x.reference.snapshots().map((e) {
                                                  for (int i = 0; i < e.get("phone_No").length; i++) {
                                                    if (e.get("auth_id")[i] != auth.currentUser!.uid) {
                                                      debugPrint("deviceNotificationToken ${e.get("deviceNotificationToken")[i]}");
                                                      debugPrint("deviceNotificationToken ${auth.currentUser!.uid}");
                                                      loginProvider.audioCallNotification(
                                                          snapshot.data!.docs[index].get("deviceNotificationToken")[i],
                                                          snapshot.data!.docs[index].get("user_name"),
                                                          snapshot.data!.docs[index].get("phone_No")[i], name.join(), "video", "Video Call");
                                                    }
                                                    // debugPrint("22211 ${e.get("phone_No")[i]}");
                                                  }
                                                }).toList();
                                                // loginProvider.audioCallNotification(snapshot.data!.docs[index].get("deviceNotificationToken"),snapshot.data!.docs[index].get("user_name"),snapshot.data!.docs[index].get("phone_No"),name.join(),"video");
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AudioCallScreen(
                                                                clientRole: ClientRole.Broadcaster,
                                                                name: snapshot.data!.docs[index].get("user_name"),
                                                                callType: "video",
                                                                number: snapshot.data!.docs[index].get("phone_No").first, channelName: channel)));
                                              }),
                                          const SizedBox(width: 10),
                                        ],
                                      ),
                                      ),
                                  ),
                                );
                              }
                              else{
                                return const SizedBox.shrink();
                              }
                            });
                      }else{
                        return const Center(child: Text("No Data found..",style: TextStyle(fontWeight: FontWeight.bold)));
                      }
                    }),
              ),
            ],
          ),
        ),
          floatingActionButton: isoffline ? null : FloatingActionButton.extended(
            heroTag: 'uniqueTag',
            backgroundColor: Colors.indigoAccent,
            label: Row(
              children: const [Text('Live  ',style: TextStyle(fontSize: 24)),Icon(Icons.live_tv,size: 35)],
            ), onPressed: () async{

            CollectionReference collection = firestore.collection('use_details');
            QuerySnapshot querySnapshots = await collection.where("auth_id", isEqualTo: auth.currentUser!.uid).get();
            QuerySnapshot querySnapshots1 = await collection.where("auth_id", isNotEqualTo: auth.currentUser!.uid).get();
            dynamic name = querySnapshots.docs.map((e) => e.get("user_name")).toList();

            querySnapshots1.docs.map((e) {
                if (e.get("auth_id") != auth.currentUser!.uid && e.get("group") == false) {
                  debugPrint("Notification ${e.get("user_name")}");
                  loginProvider.audioCallNotification(e.get("deviceNotificationToken").join(),
                      e.get("user_name"),
                      e.get("phone_No").join(), name.join(), "Audience","Live.");
                }
            }).toList();

            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => //LiveScreen(channelName: channel,)));
                        const AudioCallScreen(
                            clientRole: ClientRole.Broadcaster,
                            name: "",
                            callType: "Audience", //"Audience",
                            number: "",
                            channelName: channel)));
          },
          ),
      ),
    );
  }

  willPop() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // backgroundColor: AppColor.appColor,
            content: const Text(
              "Are you sure want to exit ?", textAlign: TextAlign.center,),
            actions: [
              MaterialButton(
                child: const Text('Yes'),
                onPressed: () {
                  // MoveToBackground.moveTaskToBack();
                  try {
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
                  } on Exception catch (e) {
                    debugPrint(e.toString());
                  }
                  // SystemNavigator.pop();
                  exit(0);
                  // exit(0);
                  // Navigator.pop(context);
                },
              ),
              MaterialButton(
                // color: AppColor.blue,
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}