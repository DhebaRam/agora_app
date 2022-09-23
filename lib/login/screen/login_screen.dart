import 'package:agora_app/utils/app_images.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../animation_screen/fade_animation.dart';
import '../provider/login provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String countryCode = '+91';
  final _phoneController = TextEditingController();
  final _userController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
            image: AssetImage(AppImage.backImage),//"assets/images/backimage.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Stack(
              children: [
                SvgPicture.asset(AppImage.wave,
                  // "assets/images/wave8.svg",
                  fit: BoxFit.fill,
                  height: height/2,
                ),
                // ! 0x00FFFFFF
                const Positioned(
                  top: 100,
                  left: 45,
                  child: FadeAnimation(
                    2,
                    Text(
                      "Agora",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: "Lobster"),
                    ),
                  ),
                )
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height/2.7),
                    FadeAnimation(
                      2,
                      Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          decoration: const BoxDecoration(color: Colors.black38,
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.person_outline,color:Colors.white,size: 30),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: TextFormField(
                                          maxLines: 1,
                                          controller: _userController,
                                            textInputAction: TextInputAction.next,
                                          style: const TextStyle(color: Colors.yellow,fontSize: 22),
                                          decoration: const InputDecoration(
                                            label: Text(" User Name ",style: TextStyle(color: Colors.white,fontSize: 18)),
                                            border: InputBorder.none,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty || value.trim().isEmpty) {
                                              return 'This Field is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 5,
                                thickness: 3,
                                indent: 50,
                                endIndent: 50,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () => showCountryPicker(
                                        context: context,
                                        showPhoneCode: true,
                                        onSelect: (Country country) {
                                          countryCode = '+' + country.phoneCode;
                                          setState(() {});
                                          debugPrint('Select country: $countryCode');
                                        },
                                      ),
                                      child: Container(
                                        // color: Colors.yellow,
                                        padding: const EdgeInsets.only(left: 0, right: 8, top: 20,bottom: 15),
                                        child: Text(
                                          countryCode,
                                          style: const TextStyle( fontSize: 22,color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        child: TextFormField(
                                          maxLines: 1,
                                          controller: _phoneController,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(color: Colors.yellow,fontSize: 22),
                                          decoration: const InputDecoration(
                                            label: Text(" Phone Number ",style: TextStyle(color: Colors.white,fontSize: 18)),
                                            border: InputBorder.none,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty || value.trim().isEmpty) {
                                              return 'This Field is required';
                                            }else if(!RegExp(r'^(?:[+0]9)?[0-9]{10}$').hasMatch(value)){
                                              return  'Enter Valid Phone Number';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    // const Icon(Icons.phone_outlined,color: Colors.white,size: 30),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 5,
                                thickness: 3,
                                indent: 50,
                                endIndent: 50,
                              ),
                              const SizedBox(height: 10),
                              Consumer<LoginProvider>(builder: (BuildContext context, loginProvider, _) {
                                return Center(
                                  child: loginProvider.isLoading ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 5)
                                      : SizedBox(
                                    width: wid,
                                    child: MaterialButton(
                                      child: const Text("LOGIN", style: TextStyle(fontSize: 22)),
                                      textColor: Colors.white,
                                      padding: const EdgeInsets.all(16),
                                      onPressed: () {
                                        final phone = countryCode + _phoneController.text.trim();
                                        if (_formKey.currentState!.validate()) {
                                          loginProvider.userName = _userController.text;
                                          loginProvider.userPhoneLogin(context, phone);
                                        }
                                        },
                                      color: const Color(0xff4f1ed2),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                            ],
                          )),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height/3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}