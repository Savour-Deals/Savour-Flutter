import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/pages/loginPages/phoneAuth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stores/settings.dart';

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
      theme: savourMaterialLightThemeData,
      darkTheme: savourMaterialDarkThemeData,
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
    for (var provider in user.providerData){
      if (provider.providerId == "phone"){
        return true;
      }
    }
    FirebaseAuth.instance.signOut();
    return false;
  }
}



