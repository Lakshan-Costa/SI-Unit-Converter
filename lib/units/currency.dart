import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:si_unit_app/main.dart';
import 'package:si_unit_app/globals.dart' as globals;
import 'package:provider/provider.dart';
import 'package:si_unit_app/main_files/feedback.dart';
import 'package:si_unit_app/main_files/ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:si_unit_app/main_files/ad_helper.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_unit_app/main_files/size_config.dart';


Future<dynamic> fetchAlbum() async {
  final response = await http.get(Uri.parse('https://api.exchangerate.host/latest'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print(jsonDecode(response.body));
    return jsonDecode(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final String motd;
  final String msg;
  final List rates;
  final double LKR;

  Album({
    required this.motd,
    required this.msg,
    required this.rates,
    required this.LKR,
  });

  factory Album.fromJson(Map<List, dynamic> json) {
    return Album(
      motd: json['motd'],
      msg: json['msg'],
      rates: json['rates'],
      LKR: json['LKR'],
    );
  }
}
// set as Currencyy because it overlaps with the currency picker! lol
class Currencyy extends StatefulWidget {
  const Currencyy({Key? key}) : super(key: key);

  @override
  _CurrencyyState createState() => _CurrencyyState();
}

class _CurrencyyState extends State<Currencyy> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(



      home: CurrencyPage(),
    );
  }
}

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({Key? key}) : super(key: key);

  @override
  _CurrencyPageState createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  late dynamic futureAlbum;


  String _val1 = "LKR";
  String _val2 = "LKR";

  String _fromcurrencyval = "";
  String _tocurrencyval = "";
  String _basecurrencyval = "";

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  late BannerAd _bannerAd;

  bool _isBannerAdReady = false;

  @override
  void initState()  {
    _getTheme();
    super.initState();
    futureAlbum = fetchAlbum();
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
      builder: (context, snapshot) {
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
                    title: Text("Currency"),
                    automaticallyImplyLeading: true,
                    leading: IconButton(icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                      },),
                  ),

                  body: Column(

                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0, 0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 150.0,
                            child: TextField(
                              controller: _controller1,
                              onChanged: (text) {
                                if(text.isNotEmpty)
                                  _controller2.text=(double.parse(text)*double.parse(_tocurrencyval)/double.parse(_fromcurrencyval)).toString();
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
                            width: 150.0,
                            child: TextField(
                              controller: _controller2,
                              onChanged: (text) {
                                if(text.isNotEmpty)
                                  _controller1.text = "0.0";

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

                      Padding(padding: EdgeInsets.fromLTRB(0.0, 10.0, 0, 0)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            child: ElevatedButton(
                              onPressed: () {
                                showCurrencyPicker(
                                  context: context,
                                  showFlag: true,
                                  showCurrencyName: true,
                                  showCurrencyCode: true,
                                  onSelect: (Currency currency) {
                                    setState(() {
                                      _val1 = currency.code;
                                    });
                                    print('From currency: ${currency.code}');

                                    //print(_val1);
                                  },
                                  favorite: ['LKR'],
                                );
                              },
                              child: Text("from $_val1 \u{2B07}"), //this should change according to what is selected.
                            ),
                          ),

                          Container(
                            child: ElevatedButton(
                              onPressed: () {
                                showCurrencyPicker(
                                  context: context,
                                  showFlag: true,
                                  showCurrencyName: true,
                                  showCurrencyCode: true,
                                  onSelect: (Currency currency) {
                                    setState(() {
                                      _val2 = currency.code;
                                    });
                                    print('To currency: ${currency.code}');
                                    _val2 = currency.code;
                                  },
                                  favorite: ['LKR'],
                                );
                              },
                              child: Text("To $_val2 \u{2B07}"), //this should change according to what is selected.
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0.0, 10.0, 0, 0)),

                      Container(
                        color: Colors.blueGrey,
                        child: FutureBuilder<dynamic>(
                          future: futureAlbum,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              _fromcurrencyval = (snapshot.data!['rates']['$_val1'].toString());
                              _tocurrencyval=(snapshot.data!['rates']['$_val2'].toString());
                              _basecurrencyval = (snapshot.data!['rates']['EUR'].toString());
                              print("$_fromcurrencyval and $_tocurrencyval ");


                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }

                            // By default, show a loading spinner.
                            return Container();
                          },
                        ),
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