import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_colors.dart';
import 'audio_call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  // final user = auth.currentUser;
  // currentUserId = user!.uid;
  @override
  Widget build(BuildContext context) {

    double wid = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return WillPopScope(
      onWillPop: () => willPop(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: height,
          decoration: const BoxDecoration(
            color: Color(0xfff96d34),
            image: DecorationImage(
              image: AssetImage("assets/images/backimage.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('use_details').where("auth_id", isNotEqualTo: "${auth.currentUser!.uid}").snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColor.blue,));
                if(snapshot.data!.size ==0) return const Center(child: Text("No Data found.."),);
                if(snapshot.hasData) {

                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context,index) {
                        Timestamp timestampTime = snapshot.data!.docs[index].get("timestamp");
                        DateTime date = timestampTime.toDate();
                        String datetime =  date.day.toString() +"/"+ date.month.toString() +"/"+ date.year.toString() ;
                        return Padding(
                          padding: const EdgeInsets.only(left: 18.0,right: 18.0,top: 5),
                          child: GestureDetector(
                            /*onLongPress: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: AppColor.appColor,
                                      content: const Text("Are you sure want to delete ?",textAlign: TextAlign.center ,),
                                      actions: [
                                        FlatButton(
                                          color: AppColor.blue,
                                          child: const Text('Yes',style: TextStyle(fontWeight: FontWeight.bold,color: AppColor.white),),
                                          onPressed: () {
                                            firestore.collection("drafts").doc(snapshot.data!.docs[index].id).delete();
                                            firestore.collection("personalDetails").doc(snapshot.data!.docs[index].id).delete();
                                            firestore.collection("academicDetails").doc(snapshot.data!.docs[index].id).delete();
                                            firestore.collection("referenceDetails").doc(snapshot.data!.docs[index].id).delete();
                                            firestore.collection("skillsDetails").doc(snapshot.data!.docs[index].id).delete();
                                            firestore.collection("userLanguageDetails").doc(snapshot.data!.docs[index].id).delete();
                                            firestore.collection("experienceDetails").doc(snapshot.data!.docs[index].id).delete();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlatButton(
                                          color: AppColor.blue,
                                          child: const Text('No',style: TextStyle(fontWeight: FontWeight.bold,color: AppColor.white)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },*/
                            child: Card(
                              child: Column(
                                children: [
                                  /*if(index % 4 == 0 && index != 0)...{
                                    SizedBox(
                                      child: Card(
                                        // color: AppColor.blue,
                                        child: AdWidget(
                                          ad:AdmobHelper.getBannerAd()..load(),
                                          key: UniqueKey(),
                                        ),
                                      ),
                                      height: 50,
                                    ),
                                  },*/
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                          padding: isLandscape ? const EdgeInsets.only(left: 70) : const EdgeInsets.only(left: 15),
                                          child: Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: AppColor.blue,
                                                  borderRadius: BorderRadius.circular(100)),
                                              child: const Icon(Icons.person,
                                                  color: AppColor.white, size: 30))
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("${snapshot.data!.docs[index].get("user_name")}",style: const TextStyle(fontWeight: FontWeight.bold,color: AppColor.blue),),
                                              Text(datetime.toString(),style: const TextStyle(color: AppColor.blue),),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(icon: const Icon(Icons.phone_outlined,color: Colors.black,size: 30), onPressed: () {
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => const AudioCallScreen()));
                                      }),
                                      const SizedBox(width: 15),
                                      IconButton(icon: const Icon(Icons.video_call_outlined,color: Colors.black,size: 30), onPressed: () {  }),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),),
                          ),
                        );
                      });
                }else{
                  return const Center(child: Text("No Data found..",style: TextStyle(fontWeight: FontWeight.bold)));
                }
              }),
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