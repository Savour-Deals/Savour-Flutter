import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  bool _darkModeEnabled = false;  
  SharedPreferences prefs;

  AppState() {
    initAppState();
  }

  Future initAppState() async {
    //see if this has been set before, if not, set to light mode
    prefs = await SharedPreferences.getInstance();
    setDarkMode(prefs.getBool('isDark') ?? false);
  }

  void setDarkMode(bool newVal) {
    _darkModeEnabled = newVal;
    prefs.setBool('isDark', _darkModeEnabled);
    notifyListeners();
  }

  bool get isDark => _darkModeEnabled;
}

class NotificationData with ChangeNotifier {
  String _notiDealID;  
  bool _notificationsEnabled = false;
  
  NotificationData();

  void setNotiDealID(String newVal) {
    _notiDealID = newVal;
    notifyListeners();
  }

  bool get isNotiDealPresent => (_notiDealID != null);

  String get consumeNotiDealID {
    var dealID = _notiDealID;
    _notiDealID = null;
    return dealID;
  }
}

class NotificationSettings with ChangeNotifier {
  bool _notificationsEnabled;
  SharedPreferences prefs;
  
  NotificationSettings(){
    initNotificationSettings();
  }

  Future initNotificationSettings() async {
    //see if this has been set before, if not, set to light mode
    prefs = await SharedPreferences.getInstance();
    setNotificationsSetting(prefs.getBool('isNotificationsEnabled') ?? false);
  }

  void setNotificationsSetting(bool newVal) {
    _notificationsEnabled = newVal;
    prefs.setBool('isNotificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  bool get isNotificationsEnabled => _notificationsEnabled;
}

