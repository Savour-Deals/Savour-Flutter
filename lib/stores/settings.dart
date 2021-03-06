import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class AppState with ChangeNotifier {
  bool _darkModeEnabled = false;  

  AppState() {
    initAppState();
  }

  Future initAppState() async {
    //see if this has been set before, if not, set to light mode
    final prefs = await SharedPreferences.getInstance();
    setDarkMode(prefs.getBool('isDark') ?? false);
    InAppPurchaseConnection.enablePendingPurchases();
  }

  Future<void> setDarkMode(bool newVal) async {
    _darkModeEnabled = newVal;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', _darkModeEnabled);
    notifyListeners();
  }

  bool get isDark => _darkModeEnabled;
}

class NotificationData with ChangeNotifier {
  String _notiDealID;  
  
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
  bool _notificationsEnabled = false;
  
  NotificationSettings(){
    initNotificationSettings();
  }

  Future initNotificationSettings() async {
    //see if this has been set before, if not, set to light mode
    final prefs = await SharedPreferences.getInstance();
    setNotificationsSetting(prefs.getBool('isNotificationsEnabled') ?? false);
  }

  Future<void> setNotificationsSetting(bool newVal) async {
    _notificationsEnabled = newVal;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isNotificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  bool get isNotificationsEnabled => this._notificationsEnabled;
}

