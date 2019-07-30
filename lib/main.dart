import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/pages/loginPages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stores/settings.dart';


void main() async { 
  runApp(InheritedStateWidget()); 
}

class SavourApp extends StatefulWidget {
  @override
  _SavourDealsState createState() => new _SavourDealsState();
}

class _SavourDealsState extends State<SavourApp> {

  SharedPreferences prefs;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    prefs = await SharedPreferences.getInstance();
    print("Dark : " + prefs.getBool('isDark').toString());
    MyInheritedWidget.of(context).data.setDarkMode(prefs.getBool('isDark') ?? false);
  }
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savour Deals',
      theme: MyInheritedWidget.of(context).data.isDark? savourMaterialDarkThemeData: savourMaterialLightThemeData,
      debugShowCheckedModeBanner: false,
      home: _handleCurrentScreen(),
    );
  }

  Widget _handleCurrentScreen() {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return new Scaffold();
        } else {
          //check if user data present
          if (snapshot.hasData) {
            var user = snapshot.data;
            //Either their email is verified or they logged in with fb
            if (verifyUser(user)){
              return new SavourTabPage(uid: snapshot.data.uid);
            }
          }
          return new LoginPage();
        }
      }
    );
  }

  verifyUser(user){
    if (user.isEmailVerified){
      //user email is verified
      return true;
    }
    for (var provider in user.providerData){
      if(provider.providerId == "facebook.com"){
        //user logged in w/ FB
        return true;
      }
    }
    return false;
  }
}



