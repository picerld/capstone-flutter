import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _userName;
  bool _isLoading = true;

  String? get userName => _userName;
  bool get isLoading => _isLoading;

  UserProvider() {
    loadUserName();
  }

  Future<void> loadUserName() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    _userName = name;
    notifyListeners();
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all data including userName and sleep data
    _userName = null;
    notifyListeners();
  }

  // Alternative: Clear only specific keys
  Future<void> clearUserDataSelective() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    // Add other keys you want to remove, for example:
    // await prefs.remove('sleepData');
    // await prefs.remove('otherData');
    _userName = null;
    notifyListeners();
  }
}
