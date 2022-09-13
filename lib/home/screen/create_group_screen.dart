import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../login/provider/login provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/get_it.dart';

class CreateGroupScreen extends StatefulWidget {
  List contact=[];
  List currentUser=[];

  CreateGroupScreen(this.contact, this.currentUser,{Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController groupName = TextEditingController();
  bool selectContectVisiblity = false;
  int selectContectvalue = 0;
  List selectList = [];
  List authId = [];
  List? phoneNo = [];
  List deviceNotificationToken = [];




  // final loginProvider = getIt<LoginProvider>();
  @override
  void initState(){
    super.initState();
    debugPrint("12121 ${widget.contact.toString()}");
    debugPrint("34434 ${widget.currentUser.toString()}");

  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("New Group",style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Add participants",style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.search)
        ],
      ),backgroundColor: Colors.indigoAccent),
      body: Column(
        children: [
          if(selectList.isNotEmpty)...{
          Container(
            height: 100,
            padding: const EdgeInsets.only(left: 18.0,right: 18.0,top: 5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
                itemCount: selectList.length,
                itemBuilder: (context,index) {
                  // Timestamp timestampTime = snapshot.data!.docs[index].get("timestamp");
                  // DateTime date = timestampTime.toDate();
                  // String datetime =  date.day.toString() +"/"+ date.month.toString() +"/"+ date.year.toString();
                  return GestureDetector(
                    onTap: (){
                      String Number = selectList[index]["phone_No"];
                      widget.contact.map((e) {
                        int indexValue = widget.contact.indexOf(e);
                        if(e["phone_No"] == Number){
                          setState(() {
                            widget.contact[indexValue]["bool"]=!widget.contact[indexValue]["bool"];
                            selectList.removeAt(index);
                          });
                        }
                      }).toList();
                      setState(() {});
                      },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: isLandscape ? const EdgeInsets.only(left: 5,top: 5,bottom: 5,right: 5) : const EdgeInsets.only(left: 5,top: 5,bottom: 5,right: 5),
                            child: Stack(children: [
                              const Padding(
                                padding: EdgeInsets.only(left:5.0,top: 3,bottom: 3,right: 5),
                                child: CircleAvatar(
                                  backgroundColor: AppColor.blue,
                                  child: Icon(Icons.person,
                                      color: AppColor.white, size: 30),
                                ),
                              ),
                              if(selectList[index]["bool"] == true)...{
                                const Positioned(
                                  right: 1,
                                  bottom: 3,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    radius: 8,
                                    child: Icon(Icons.clear, color: AppColor.white,size: 15),
                                  ),
                                )}
                            ],

                            )
                        ),
                        Text("${selectList[index]["user_name"]}")
                      ],
                    ),
                  );

                }),
          )},
          Expanded(
            child: ListView.builder(
                        itemCount: widget.contact.length,
                        itemBuilder: (context,index) {
                          if(widget.currentUser.first.toString() == widget.contact[index].toString()){
                            return Container();
                          }else{
                           return Padding(
                              padding: const EdgeInsets.only(left: 18.0,right: 18.0,top: 5),
                              child: GestureDetector(
                                onTap: (){
                                  if(widget.contact[index]["bool"]==false){
                                    setState(() {
                                      widget.contact[index]["bool"]=!widget.contact[index]["bool"];
                                      selectList.add(widget.contact[index]);
                                      selectList = selectList.toSet().toList();
                                    });

                                  }else{
                                    print("1 ${widget.contact[index]["bool"]}");
                                    if(widget.contact[index]["bool"]==true){
                                      selectList.map((e) {
                                        if(e["phone_No"]==widget.contact[index]["phone_No"]){
                                          int indexValue = selectList.indexOf(e);
                                          setState(() {
                                            widget.contact[index]["bool"]=!widget.contact[index]["bool"];
                                            print("2 ${widget.contact[index]["bool"]}");
                                            selectList.removeAt(indexValue);
                                          });
                                        }
                                      }).toList();
                                      setState(() {

                                      });
                                    }
                                    // widget.contact[index]["bool"]=!widget.contact[index]["bool"];
                                    // print("3 ${widget.contact[index]["bool"]}");
                                    // selectList.remove(index);
                                    // setState(() {});
                                  }
                                },
                                child: Card(
                                  child:
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                          padding: isLandscape ? const EdgeInsets.only(left: 70,top: 5,bottom: 5) : const EdgeInsets.only(left: 15,top: 5,bottom: 5),
                                          child: Stack(children: [
                                            const Padding(
                                              padding: EdgeInsets.only(left: 8.0,top: 3,bottom: 3,right: 5),
                                              child: CircleAvatar(
                                                backgroundColor: AppColor.blue,
                                                child: Icon(Icons.person,
                                                    color: AppColor.white, size: 30),
                                              ),
                                            ),
                                            if(widget.contact[index]["bool"] == true)...{
                                              const Positioned(
                                                right: 1,
                                                bottom: 3,
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.teal,
                                                  radius: 8,
                                                  child: Icon(Icons.check,color: AppColor.white,size: 15),
                                                ),
                                              )}
                                          ],

                                          )
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("${widget.contact[index]["user_name"]}",style: const TextStyle(fontWeight: FontWeight.bold,color: AppColor.blue,fontSize: 18),),
                                              Text("${widget.contact[index]["phone_No"]}",style: const TextStyle(color: AppColor.blue),),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                  /*const SizedBox(height: 10),
                                            ],
                                          ),*/),
                              ),
                            );
                          }
                          // Timestamp timestampTime = snapshot.data!.docs[index].get("timestamp");
                          // DateTime date = timestampTime.toDate();
                          // String datetime =  date.day.toString() +"/"+ date.month.toString() +"/"+ date.year.toString();

                        }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                insetPadding: const EdgeInsets.all(5),
                content: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          color: AppColor.white,
                          child: TextField(
                            controller: groupName,
                            maxLines: 2,
                            minLines: 1,
                            textInputAction: TextInputAction.done,
                            focusNode: FocusNode(),
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                                contentPadding:
                                EdgeInsets.fromLTRB(07, 00, 00, 04),
                                hintText: 'Group Name',
                                hintStyle: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                          ),
                        ),
                        TextButton(
                            onPressed: () {

                              if(selectList.isNotEmpty){
                                print("length ${selectList.first}");
                                selectList.add(widget.currentUser.join());
                                print("length1 ${selectList}");
                                print("length ${selectList.length}");
                                selectList.map((e) {
                                  authId.add(e["auth_id"]);
                                  phoneNo!.add(e["phone_No"]);
                                  deviceNotificationToken.add(e["deviceNotificationToken"]);
                                }).toList();
                                print("length ${selectList[0]["user_name"]}");
                                final loginProvider = getIt<LoginProvider>();
                                Map<String, dynamic> userDetails = {"auth_id": authId, "phone_No":phoneNo, 'user_name': groupName.text, 'deviceNotificationToken': deviceNotificationToken, 'timestamp': DateTime.now(),"bool":false,"group":true};
                                print("User Details $userDetails");
                                loginProvider.createGroupDetails(phoneNo!,userDetails,context);
                                // Navigator.pop(context);
                                selectList.clear();
                              }


                              /*if (languageController.text.isNotEmpty) {
                                Navigator.pop(context);
                                homeProvider.setSkillsData(
                                    languageController.text,
                                    snapshot.skills == "It Field"
                                        ? "IT(Technical)"
                                        : "Non-IT(Technical)");
                                languageController.clear();
                                fieldController.clear();
                              } else {
                                AppUtils.instance.showToast(
                                    toastMessage: "Skills Is Not Empty..");
                              }*/
                            },
                            child: Container(
                              child: const Text("Create",
                                  style: TextStyle(
                                      color: AppColor.white, fontSize: 18,fontWeight: FontWeight.bold)),
                              decoration: BoxDecoration(
                                  color: selectList.isEmpty ? AppColor.grayshade : AppColor.blue,
                                  borderRadius: const BorderRadius.all(Radius.circular(5))),
                              padding: const EdgeInsets.only(
                                  left: 25, right: 25, top: 10, bottom: 10),
                            ))
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },

        backgroundColor: AppColor.blue,
        child: const Icon(Icons.group_add,size: 25,)
      )
    );
  }
}
