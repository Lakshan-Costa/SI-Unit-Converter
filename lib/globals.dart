library my_prj.globals;
import 'package:flutter/material.dart';


String instruction = "* Enter values after selecting the unit type.";

//remove ads bool
bool ads = false;
Future ?adsF;

//light/dark theme globals
bool light = true;
Future? lightF;


class ThemeModel with ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  ThemeModel({ThemeMode mode = ThemeMode.light}) : _mode = mode;

  void toggleMode() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
