import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:si_unit_app/main_files/ads.dart';
import 'package:si_unit_app/globals.dart' as globals;
import 'package:provider/provider.dart';
import 'package:si_unit_app/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:si_unit_app/main_files/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {

  @override
  void initState() {
    // TODO: implement initState
    _getTheme();
    super.initState();
  }

  Future <SharedPreferences> _prefs = SharedPreferences.getInstance();

  _saveTheme() async{
    SharedPreferences pref = await _prefs;
    pref.setBool('theme', globals.light);
  }

  _getTheme() async{
    globals.lightF = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('theme') != null ? prefs.getBool('theme') : false;
    });
    globals.light = await globals.lightF;
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<globals.ThemeModel>(
      create: (_) => globals.ThemeModel(),
      child: Consumer<globals.ThemeModel>(
        builder: (_, model, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!);
            },
            theme: ThemeData.light(), // Provide light theme.
            darkTheme: ThemeData.dark(), // Provide dark theme.
            themeMode: globals.light ? ThemeMode.dark : ThemeMode.light, // Decides which theme to show.
            home: Scaffold(
              appBar: AppBar(
                leading: IconButton(icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));    //CHANGE THIS SO THAT IT WILL GO BACK TO THE SCREEN
                  },),
                title: Text("Feedback"),
                actions: [
                  PopupMenuButton(
                      onSelected: (result) {
                        if (result == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FeedbackPage()),
                          );
                        }
                        if (result == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RemoveAdsPage()),
                          );
                        }
                        if (result ==3) {

                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text("Feedback",style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4.5),), value: 1,),
                        PopupMenuItem(child: Text("Remove Ads",style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4.5),), value: 2,),
                        PopupMenuItem(
                          child: StatefulBuilder(
                            builder: (BuildContext context,
                                StateSetter setState) {
                              return Row(
                                children: [
                                  Switch(
                                    value: globals.light, onChanged: (changed) {
                                    setState(() {
                                      model.toggleMode();
                                      globals.light = changed;
                                    });
                                    _saveTheme();
                                  },
                                  ),


                                  Text("Dark Mode ",style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4.5),), Icon(Icons.dark_mode_outlined, color: Colors.blueGrey,),
                                ],
                              );
                            },
                          ),
                        ),
                      ]),
                ],
              ),
              body: Feedback(),
            ),
          );
        },
      ),
    );
  }
}


class Feedback extends StatefulWidget {
  const Feedback({Key? key}) : super(key: key);

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {

  String email = "";
  String userText = "";
  final emailController = TextEditingController();
  final userTextController = TextEditingController();

  final _emailkey = GlobalKey<FormState>();
  final _usertextkey = GlobalKey<FormState>();


  int textlen = 15;

  bool _validate = false;


  @override
  void dispose() {
    emailController.dispose();
    userTextController.dispose();
    super.dispose();
  }

  //drop down menu
  String _message = "Issues with the app";

  //getting the image from the gallery and displaying it on the app
  File? _image;
  final imagePicker = ImagePicker();

  Future getImage() async{
    final image = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(image!.path);
    });
  }


  //upload to firebase storage
  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = basename(_image!.path);
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child("image1" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(_image!);
    uploadTask.then((res) {
      res.ref.getDownloadURL();
    });

  }

  //snackbar on the bottom to say after feedback submitted.
  final snackBar = SnackBar(content: Text("Thank you for your Feedback!"));



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: globals.lightF,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(SizeConfig.safeBlockVertical*1.25, SizeConfig.safeBlockVertical*1.25, SizeConfig.safeBlockVertical*1.25, 0.0),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      ///padding: EdgeInsets.fromLTRB(0.0, SizeConfig.safeBlockVertical*1.25, 0.0, 0.0),


                      child: DropdownButton<String>(
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem(child: Text("Issues with the app"), value: "Issues with the app",
                            onTap: () {
                              _message = _message;
                            },),

                          DropdownMenuItem(child: Text("Unit value errors"), value: "Unit value errors", onTap: () {
                            _message = _message;
                          },),


                          DropdownMenuItem(child: Text("Need to add more units"), value: "Need to add more units",
                            onTap: () {
                              _message = _message;
                            },),

                          DropdownMenuItem(child: Text("Other"), value: "Other",
                            onTap: () {
                              _message = _message;
                            },),


                        ],
                        onChanged: (value) {
                          setState(()  {
                            this._message = value!;

                          });
                        },
                        value: _message,

                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(SizeConfig.safeBlockVertical*1.5),
                  child: Form(
                    key: _emailkey,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: (value) => EmailValidator.validate(value!) ? null : "Please enter a valid email",
                      controller: emailController,
                      decoration: InputDecoration(
                          errorText: _validate ? "error" : null,
                          border: OutlineInputBorder(),
                          labelText: ("email")
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: new TextStyle(
                        fontFamily: "Poppins",
                      ),
                    ),

                  ),
                ),



                Container(
                  height: SizeConfig.safeBlockVertical*22.5,
                  padding: EdgeInsets.all(SizeConfig.safeBlockVertical*1.5),
                  child: Form(
                    key: _usertextkey,
                    child: TextFormField(
                      onChanged: (value) {
                        textlen = 15 - userTextController.text.length;
                        if (value.length ==0) {
                          return null;
                        }
                      },
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if(value!.length>0 && value.length<15) {
                          return "$textlen more to go...";
                        } else if(value.length>=15) {
                          return null;
                        }


                      },
                      maxLines: 5,
                      controller: userTextController,
                      decoration: InputDecoration(
                          errorText: _validate ? 'Please enter a description ' : null,
                          border: OutlineInputBorder(),
                          labelText: ("Tell us what's wrong, Phone Model..."),
                      ),
                      keyboardType: TextInputType.multiline,
                      style: new TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(

                      height: SizeConfig.safeBlockVertical*18.75,
                      child: _image == null ? Text('No image selected.') : Image.file(_image!),

                    ),
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: getImage,
                        child: Text("Gallery")),

                    /*
              ElevatedButton(
                  onPressed: () {},
                  child: Text("Take Screenshot")), */
                  ],
                ),
                Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.safeBlockVertical*6.25, 0.0, 0.0)),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(

                        onPressed: () {
                          if (userTextController.text.length == 0) {
                            setState(() {
                              userTextController.text.isEmpty ? _validate = true : _validate = false;
                            });
                          }
                          if (_emailkey.currentState!.validate() && _usertextkey.currentState!.validate() && userTextController.text.length >=15) {
                            Map <String,dynamic> email = {"email": emailController.text, "user_text": userTextController.text, "issueType": _message};
                            FirebaseFirestore.instance.collection("description").add({"entry" + DateTime.now().toString(): email}).then((_) => print("Success"));
                            uploadImageToFirebase(context);
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);

                          } else return null; //if inputs are wrong!
                          final bool isValid = EmailValidator.validate(emailController.text);

                          //print(userTextController.text.length);
                          //print(isValid);
                          //print(emailController.text);
                          //print(userTextController.text);
                          //print(_message);



                        }, child: Text("Submit")),

                  ],
                ),



              ],
            ),

          ),
        );
      },
    );

  }
}