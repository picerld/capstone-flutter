import 'package:flutter/material.dart';

class NavProvider extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void setIndex(BuildContext context, int i) {
    if (_index == i) return;
    _index = i;
    notifyListeners();

    switch (i) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/score');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/analytics');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  void resetIndex(BuildContext context) {
    _index = 0;
    notifyListeners();
  }
}
