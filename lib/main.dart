import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:si_unit_app/main_files/feedback.dart';
import 'package:si_unit_app/main_files/ads.dart';
import 'package:si_unit_app/globals.dart' as globals;
import 'package:provider/provider.dart';
import 'package:si_unit_app/units/area.dart';
import 'package:si_unit_app/units/digital_storage.dart';
import 'package:si_unit_app/units/digital_transfer_rate.dart';
import 'package:si_unit_app/units/energy.dart';
import 'package:si_unit_app/units/frequency.dart';
import 'package:si_unit_app/units/fuel_economy.dart';
import 'package:si_unit_app/units/length.dart';
import 'package:si_unit_app/units/mass.dart';
import 'package:si_unit_app/units/plane_angle.dart';
import 'package:si_unit_app/units/pressure.dart';
import 'package:si_unit_app/units/speed.dart';
import 'package:si_unit_app/units/time.dart';
import 'package:si_unit_app/units/volume.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:si_unit_app/main_files/ad_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:si_unit_app/units/currency.dart';
import 'package:si_unit_app/units/temperature.dart';
import 'package:si_unit_app/main_files/size_config.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Provider.debugCheckInvalidValueType = null;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    //SizeConfig().init(context);
    return MaterialApp(
      title: "Units",
      builder: (context, child) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!);
      },
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        duration: 500,
        nextScreen: HomePage(),
        splashTransition: SplashTransition.fadeTransition,
        splashIconSize: 500,
        splash: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/splashscreen.png", height: 200, width: 100),
            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0),),
            Text("Unit converter", textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
          ],
        ),

      ),
    );
  }
}

//Future? _lightF;


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    _getTheme();
    _getAds();
    super.initState();
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
  void dispose() {
    //TODO: Dispose a BannerAd object
    _bannerAd.dispose();
    super.dispose();
  }


  Future <SharedPreferences> _prefs = SharedPreferences.getInstance();

  _getAds() async {
    globals.adsF = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('ads') != null ? prefs.getBool('ads') : false;
    });
    globals.ads = await globals.adsF;
  }

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
    SizeConfig().init(context);

    return FutureBuilder(
      future: globals.lightF,
      builder: (context, snapshot) {
        return ChangeNotifierProvider<globals.ThemeModel>(
          create: (_) => globals.ThemeModel(),
          child: Consumer<globals.ThemeModel>(
            builder: (_, model, __) {
              return MaterialApp(
                title: "Units",
                builder: (context, child) {
                  return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: child!);
                },
                debugShowCheckedModeBanner: false,
                theme: ThemeData.light(),
                // Provide light theme.
                darkTheme: ThemeData.dark(),
                // Provide dark theme.
                themeMode: globals.light ? ThemeMode.dark : ThemeMode.light,
                // Decides which theme to show.
                home: Scaffold(
                  appBar: AppBar(
                    title: Text("Select Unit"),
                    actions: [
                      PopupMenuButton(
                          onSelected: (result) {
                            if (result == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FeedbackPage()),
                              );
                            }
                            if (result == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RemoveAdsPage()),
                              );
                            }
                            if (result == 3) {

                            }
                          },
                          itemBuilder: (context) =>
                          [
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
                  body: Container(
                    padding: EdgeInsets.all(SizeConfig.safeBlockVertical*2.5),
                    child: Column(
                      children: [
                        new Expanded(
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              children: [
                                ElevatedButton(

                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => LengthPage()));
                                  },
                                  child: Text("Length", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),),),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => MassPage()));
                                    },
                                    child: Text("Mass", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => TimePage()));
                                    },
                                    child: Text("Time", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => EnergyPage()));
                                    },
                                    child: Text("Energy", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => AreaPage()));
                                    },
                                    child: Text("Area", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => PressurePage()));
                                    },
                                    child: Text("Pressure", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => SpeedPage()));
                                    },
                                    child: Text("Speed", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => VolumePage()));
                                    },
                                    child: Text("Volume", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => FrequencyPage()));
                                    },
                                    child: Text("Frequency", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => PlaneAnglePage()));
                                    },
                                    child: Text("Plane Angle", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                              DigitalStoragePage()));
                                    },
                                    child: Text("Digital Storage", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                              DigitalTransferRatePage()));
                                    },
                                    child: Text("Digital Transfer Rate", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => FuelEconomyPage()));
                                    },
                                    child: Text("Fuel Economy", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => CurrencyPage()));
                                    },
                                    child: Text("Currency", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4, fontWeight: FontWeight.bold),)),

                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => TemperaturePage()));
                                    },
                                    child: Text("Temperature", textAlign: TextAlign.center, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*3.36, fontWeight: FontWeight.bold),)),



                              ],
                            )
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(0, SizeConfig.safeBlockHorizontal*1.375, 0, 0)),


                        // TODO: Display a banner when ready
                        if(_isBannerAdReady)
                          Align(
                            alignment: Alignment.topCenter,
                            child:!globals.ads ? Container(
                              width: _bannerAd.size.width.toDouble(),
                              height: _bannerAd.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd,),
                            ) : SizedBox(),
                          ),


                      ],
                    ),
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