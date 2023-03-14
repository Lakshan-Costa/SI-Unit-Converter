import 'package:flutter/material.dart';
import 'package:si_unit_app/main.dart';
import 'package:si_unit_app/valueTables/areavalue.dart';
import 'package:si_unit_app/globals.dart' as globals;
import 'package:provider/provider.dart';
import 'package:si_unit_app/main_files/feedback.dart';
import 'package:si_unit_app/main_files/ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:si_unit_app/main_files/ad_helper.dart';
import 'package:si_unit_app/main_files/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Area extends StatefulWidget {
  const Area({Key? key}) : super(key: key);

  @override
  _AreaState createState() => _AreaState();
}

class _AreaState extends State<Area> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AreaPage(),
    );
  }
}

class AreaPage extends StatefulWidget {
  const AreaPage({Key? key}) : super(key: key);

  @override
  _AreaPageState createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {

  String _val1 = "Square kilometer";
  String _val2 = "Square kilometer";
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  late BannerAd _bannerAd;

  bool _isBannerAdReady = false;

  @override
  void initState()  {
    _getTheme();
    super.initState();
    _controller1=TextEditingController();
    _controller2=TextEditingController();
    //TODO: Initialize _bannerAd
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print("Failed to load a banner ad: ${err.message}");
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose(){
    _bannerAd.dispose();
    super.dispose();
    _controller1.dispose();
    _controller2.dispose();
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
    return FutureBuilder(
      future: globals.lightF,
      builder: (context,snapshot) {
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
                    title: Text("Area"),
                    automaticallyImplyLeading: true,
                    leading: IconButton(icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                      },),
                  ),
                  body: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(0.0, SizeConfig.safeBlockVertical*12.5, 0.0, 0.0),
                            width: SizeConfig.safeBlockHorizontal*40,

                            child: TextField(
                              controller: _controller1,
                              onChanged: (text) {
                                if(text.isNotEmpty)
                                  _controller2.text=(double.parse(text)*changes[_val1+"-"+_val2]).toString();
                                else
                                  _controller2.text = "0.0";
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: ("Enter Value")
                              ),
                              keyboardType: TextInputType.number,
                              style: new TextStyle(
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0.0, SizeConfig.safeBlockVertical*12.5, 0.0, 0.0),
                            width: SizeConfig.safeBlockHorizontal*40,
                            child: TextField(
                              controller: _controller2,
                              onChanged: (text) {
                                if(text.isNotEmpty)
                                  _controller1.text=(double.parse(text)*changes[_val2+"-"+_val1]).toString();

                                else
                                  _controller1.text = "0.0";

                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: ("Enter Value")
                              ),
                              keyboardType: TextInputType.number,
                              style: new TextStyle(
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                        ],
                      ),






                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(SizeConfig.safeBlockHorizontal*1.25, SizeConfig.safeBlockVertical*1.25, 0.0, 0.0),
                            width: SizeConfig.safeBlockHorizontal*45,

                            child: DropdownButton<String>(
                              items: <DropdownMenuItem<String>>[
                                DropdownMenuItem(child: Text("Square kilometer",), value: "Square kilometer", onTap: () {
                                  _val1 = _val1;


                                },),
                                DropdownMenuItem(child: Text("Square meter"), value: "Square meter",
                                  onTap: () {
                                    _val1 = _val1;
                                  },),

                                DropdownMenuItem(child: Text("Square mile"), value: "Square mile",
                                  onTap: () {
                                    _val1 = _val1;
                                  },),

                                DropdownMenuItem(child: Text("Square yard"), value: "Square yard",
                                  onTap: () {
                                    _val1 = _val1;
                                  },),

                                DropdownMenuItem(child: Text("Square foot"), value: "Square foot",
                                  onTap: () {
                                    _val1 = _val1;
                                  },),

                                DropdownMenuItem(child: Text("Square inch"), value: "Square inch",
                                  onTap: () {
                                    _val1 = _val1;
                                  },),

                                DropdownMenuItem(child: Text("Hectare"), value: "Hectare",
                                  onTap: () {
                                    _val1 = _val1;
                                  },),

                                DropdownMenuItem(child: Text("Acre"), value: "Acre",
                                  onTap: () {
                                    _val1 = _val1;
                                  },),

                              ],
                              onChanged: (value) {
                                setState(()  {
                                  this._val1 = value!;
                                });
                              },
                              value: _val1,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(SizeConfig.safeBlockHorizontal*1.25, SizeConfig.safeBlockVertical*1.25, 0.0, 0.0),
                            width: SizeConfig.safeBlockHorizontal*45,
                            child: DropdownButton<String>(
                              items: <DropdownMenuItem<String>>[
                                DropdownMenuItem(child: Text("Square kilometer"), value: "Square kilometer", onTap: () {
                                  _val2 = _val2;


                                },),
                                DropdownMenuItem(child: Text("Square meter"), value: "Square meter",
                                  onTap: () {
                                    _val2 = _val2;
                                  },),

                                DropdownMenuItem(child: Text("Square mile"), value: "Square mile",
                                  onTap: () {
                                    _val2 = _val2;
                                  },),

                                DropdownMenuItem(child: Text("Square yard"), value: "Square yard",
                                  onTap: () {
                                    _val2 = _val2;
                                  },),

                                DropdownMenuItem(child: Text("Square foot"), value: "Square foot",
                                  onTap: () {
                                    _val2 = _val2;
                                  },),

                                DropdownMenuItem(child: Text("Square inch"), value: "Square inch",
                                  onTap: () {
                                    _val2 = _val2;
                                  },),

                                DropdownMenuItem(child: Text("Hectare"), value: "Hectare",
                                  onTap: () {
                                    _val2 = _val2;
                                  },),

                                DropdownMenuItem(child: Text("Acre"), value: "Acre",
                                  onTap: () {
                                    _val2 = _val2;
                                  },),
                              ],
                              onChanged: (value) {
                                setState(()  {
                                  this._val2 = value!;
                                });
                              },
                              value: _val2,
                            ),
                          ),


                        ],
                      ),
                      Padding(padding: EdgeInsets.all(SizeConfig.safeBlockVertical*2.5)),
                      Container(
                        child: Text(globals.instruction, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*3.5, fontWeight: FontWeight.bold),),
                      ),
                      // TODO: Display a banner when ready
                      if(_isBannerAdReady)
                        Expanded(child: Align(
                          alignment: Alignment.bottomCenter,
                          child:!globals.ads ? Container(
                            width: _bannerAd.size.width.toDouble(),
                            height: _bannerAd.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd,),
                          ) : SizedBox(),
                        ),),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, SizeConfig.safeBlockVertical*2.5)),
                    ],

                  ),


                ),
              );
            },
          ),
        );
      },
    );
  }
}
