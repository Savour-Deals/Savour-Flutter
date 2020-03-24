import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/pages/loginPages/phoneAuth.dart';
// import 'package:savour_deals_flutter/pages/loginPages/loginPage.dart';
// import 'package:savour_deals_flutter/pages/loginPages/phoneAuth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stores/settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() async { 
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
        ),
        ChangeNotifierProvider<NotificationData>(
          create: (_) => NotificationData(),
        ),
        ChangeNotifierProvider<NotificationSettings>(
          create: (_) => NotificationSettings(),
        ),
      ],
      child: SavourApp(),
    )
  ); 
}

class SavourApp extends StatefulWidget {
  @override
  _SavourDealsState createState() => new _SavourDealsState();
}

class _SavourDealsState extends State<SavourApp> {

  SharedPreferences prefs;
  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savour Deals',
      theme: Provider.of<AppState>(context).isDark? savourMaterialDarkThemeData: savourMaterialLightThemeData,
      debugShowCheckedModeBanner: false,
      home: _handleCurrentScreen(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }

  Widget _handleCurrentScreen() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold();
        } else {
          //check if user data present
          if (snapshot.hasData) {
            var user = snapshot.data;

            //Either their email is verified or they logged in with fb
            if (verifyUser(user)){
              FirebaseDatabase.instance.goOnline(); //Re-enable connection to database when logged in
              return MediaQuery(
                child: SavourTabPage(uid: snapshot.data.uid),
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              ); 
            }
          }
          FirebaseDatabase.instance.goOffline(); //If logged out, disbale db connection
          return MediaQuery(
            child: PhoneAuth(),
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          );
        }
      }
    );
  }

  verifyUser(FirebaseUser user){
    return true;
    // if (user.isEmailVerified){
    //   //user email is verified
    //   return true;
    // }
    // for (var provider in user.providerData){
    //   if(provider.providerId == "facebook.com"){
    //     //user logged in w/ FB
    //     _collectFBData(user);
    //     return true;
    //   }
    // }
    // FirebaseAuth.instance.signOut();
    // return false;
  }

  void _collectFBData(FirebaseUser user) async{
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child("Users").child(user.uid);
      var facebook = new FacebookLogin();
      var accessToken = await facebook.currentAccessToken;

      var graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${accessToken.token}');

      var profile = json.decode(graphResponse.body);
      if (profile['name'] != null){
        userUpdateInfo.displayName = profile['name'];
        userRef.child("full_name").set(profile['name']);
      }
      if (profile['id'] != null){
        userRef.child("facebook_id").set(profile['id']);
      }
      if (profile['email'] != null){
        userRef.child("email").set(profile['email']);
      }
      user.updateProfile(userUpdateInfo);
  }
}



