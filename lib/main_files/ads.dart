import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:si_unit_app/main_files/feedback.dart';
import 'package:si_unit_app/globals.dart' as globals;
import 'package:si_unit_app/main.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:si_unit_app/main_files/ad_helper.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:si_unit_app/main_files/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoveAdsPage extends StatefulWidget {
  const RemoveAdsPage({Key? key}) : super(key: key);

  @override
  _RemoveAdsPageState createState() => _RemoveAdsPageState();
}

class _RemoveAdsPageState extends State<RemoveAdsPage> {

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
            home: DefaultTabController(
              length: 2,
              child: Scaffold(
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
                  title: Text("Remove Ads"),
                  automaticallyImplyLeading: true,
                  leading: IconButton(icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));    //CHANGE THIS SO THAT IT WILL GO BACK TO THE SCREEN
                    },),
                  bottom: TabBar(tabs: [
                    Text("Remove Ads", style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal*3.75, fontWeight: FontWeight.bold),),
                    Text("Buy me a Coffee", style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*3.75, fontWeight: FontWeight.bold),),
                  ]),// YOU CAME FROM
                ),
                body: RemoveAds(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RemoveAds extends StatefulWidget {
  const RemoveAds({Key? key}) : super(key: key);

  @override
  _RemoveAdsState createState() => _RemoveAdsState();
}

class _RemoveAdsState extends State<RemoveAds> {

  //bannerads
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState()  {

    super.initState();
    _getAds();
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
  void dispose () {
    //TODO: Dispose a BannerAd object
    _bannerAd.dispose();
    super.dispose();
  }

  //donations
  String _donations = "Bitcoin";
  String image_qrcode = "assets/images/bitcoin.png";
  ///Check the addresses again!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  String Address = "3JSuNKToLo7nKcLTW4HsKb39NqJcWcyech"; //this is the btc wallet address


  Future <SharedPreferences> _prefs = SharedPreferences.getInstance();

  _saveAds() async {
    SharedPreferences pref = await _prefs;
    pref.setBool('ads', globals.ads);
  }

  _getAds() async {
    globals.adsF = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('ads') != null ? prefs.getBool('ads') : false;
    });
    globals.ads = await globals.adsF;
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var screenSize = MediaQuery.of(context).size;
    print(screenSize);

    return FutureBuilder(
      future: globals.lightF,
      builder: (context, snapshot) {
        return TabBarView(
          children: [
            Column(

              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(SizeConfig.safeBlockVertical*3, 0, SizeConfig.safeBlockVertical*3, 0),
                  child: Column(
                    children: [
                      Container(
                        child: Switch(
                          value: globals.ads, onChanged: (value) {
                          setState(() {
                            globals.ads = value;
                          });
                          _saveAds();
                        },
                        ),
                      ),
                      !globals.ads ? Container(
                        padding: EdgeInsets.all(SizeConfig.safeBlockVertical*1.5),
                        color: Colors.lightGreen,
                        child: Text("If you are seeing this green box that means ads are displayed across the app. You can remove the ads by turning the switch ON. Then You will no longer see any ads. And Yes, It's free.", style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*3.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),

                      ) : SizedBox(),

                      globals.ads ? Container(
                        padding: EdgeInsets.all(SizeConfig.safeBlockVertical*1.5),
                        color: Colors.red,
                        child: Text("If you are seeing this red box that means ads are turned off throughtout the App. You can turn on the ads by sliding the switch above to the left side.", style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*3.5, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),

                      ) : SizedBox(),

                    ],
                  ),
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
            Container(
              padding: EdgeInsets.fromLTRB(SizeConfig.safeBlockHorizontal*2.5, 0.0, SizeConfig.safeBlockHorizontal*2.5, 0.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.safeBlockVertical*3.125, 0.0, 0.0),),
                  Container(
                    height: SizeConfig.safeBlockVertical * 60,
                    width: SizeConfig.safeBlockHorizontal * 85,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.safeBlockVertical*3.75),
                      ),
                      elevation: 15.0,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(SizeConfig.safeBlockHorizontal*1.25, 0.0, SizeConfig.safeBlockHorizontal*1.25, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.safeBlockVertical*2.5, 0.0, 0.0)),
                            Container(
                              width: SizeConfig.safeBlockHorizontal*70,
                              height: SizeConfig.safeBlockVertical*35,
                              child: Image(image: AssetImage(image_qrcode)), //this has to change
                            ),

                            Align(
                              child: Padding(padding: EdgeInsets.fromLTRB(0.0, SizeConfig.safeBlockVertical*1.25, 0.0, SizeConfig.safeBlockVertical*1.25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal*77,
                                      height: SizeConfig.safeBlockVertical*15,
                                      child: Card(
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(SizeConfig.safeBlockVertical*2.5),

                                        ),
                                        child: Padding(padding: EdgeInsets.all(SizeConfig.safeBlockVertical*1.875),
                                          child: Column(
                                            children: [
                                              Text(Address, style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*2.7),),
                                              Container(
                                                alignment: Alignment.center,
                                                width: SizeConfig.safeBlockHorizontal*15,
                                                child: ElevatedButton(onPressed: () {
                                                  Clipboard.setData(ClipboardData(text: Address));
                                                  Fluttertoast.showToast(msg: "Address copied to clipboard",
                                                    gravity: ToastGravity.CENTER,
                                                  );
                                                },
                                                  child: Icon(Icons.content_copy),),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Container(
                    child: DropdownButton<String>(
                      items: <DropdownMenuItem<String>>[
                        DropdownMenuItem(child: Text("Bitcoin"), value: "Bitcoin", onTap: () {
                          _donations = _donations;
                          image_qrcode = "assets/images/bitcoin.png";
                          Address = "3JSuNKToLo7nKcLTW4HsKb39NqJcWcyech";

                        },),

                        DropdownMenuItem(child: Text("Ethereum"), value: "Ethereum", onTap: () {
                          _donations = _donations;
                          image_qrcode = "assets/images/ethereum.jpg";
                          Address = "0x893b4F9881c6FaAB56E00b2b0E71282cf8CD2AEE";

                        },),

                        DropdownMenuItem(child: Text("Dogecoin"), value: "Dogecoin", onTap: () {
                          _donations = _donations;
                          image_qrcode = "assets/images/dogecoin.jpg";
                          Address = "DSSG5Ngp749peCVTR5uuUtuYErB2FpV7Br";
                        },),
                        /*
                        DropdownMenuItem(child: Text("Paypal"), value: "Paypal", onTap: () {
                          _donations = _donations;
                          image_qrcode = "assets/images/paypal.jpg";

                        },),*/
                      ],
                      onChanged: (value) {
                        setState(() {
                          this._donations = value!;
                        });

                      },
                      value: _donations,
                    ),
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  ),

                ],
              ),
            ),
          ],

        );
      },
    );
  }
}
