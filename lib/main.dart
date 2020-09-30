import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/pages/loginPages/phoneAuth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savour_deals_flutter/globals/themes/theme.dart';
import 'package:savour_deals_flutter/pages/tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'globals/enums/notificationTypeEnum.dart';
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  NotificationData notificationData;

  @override
  initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });

    notificationData = Provider.of<NotificationData>(context, listen: false);

    //setup remote notifications
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _handleMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _handleNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _handleNotification(message);
      },
    );

    _firebaseMessaging.subscribeToTopic("MOBILE");
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print(token);
    });
  }


  Future<void> _handleNotification (Map<dynamic, dynamic> message) async {
    var data = message['data'] ?? message;
    switch(NotificationTypeEnum.fromString(data['type'])){
      case NotificationTypeEnum.DEAL:
        var dealId = data['dealId'];
        print('Deal notification for dealId tapped: ${dealId}');
        notificationData.setNotiDealID(dealId);
        break;
      case NotificationTypeEnum.LINK:
        var url = data['url'];
        print('Link notification for url tapped: ${url}');
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
        break;
      case NotificationTypeEnum.NOTIFICATION:
        print('Simple system notification tapped. Nothing else to do here.');
        break;
      default:
        print('Unrecognized notification type. Cannot handle notification.');
    }
  }

  Future<void> _handleMessage (Map<dynamic, dynamic> message) async {
    var data = message['data'] ?? message;
    var notification;
    var image = data['image_url'];
    if(Platform.isIOS){
      notification = data['aps']['alert'] ?? {};
    }else if (Platform.isAndroid) {
      notification = message['notification']?? {};
    }

    showOverlay((context, t) {
      return  SafeArea(
        child: Column(
          children:[
            Container(
              clipBehavior: Clip.hardEdge,
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .cardColor,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Theme
                        .of(context)
                        .shadowColor,
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: Material(
                  child: GestureDetector(
                    onTap: () {
                      OverlaySupportEntry.of(context).dismiss();
                      _handleNotification(message);
                    },
                    child: ListTile(
                      leading: image == null? null :
                      Container(
                        child: Image(
                          image: AdvancedNetworkImage(
                            image,
                            useDiskCache: true,
                            cacheRule: CacheRule(maxAge: const Duration(days: 1)),
                            scale: 0.2,
                            printError: true,
                          ),
                          fit: BoxFit.cover,
                        ),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      title: Text(notification['title'] ?? ""),
                      subtitle: Text(notification['body'] ?? ""),
                    ),
                  )
              ),
            ),
          ],
        ),
      );
    }, duration: Duration(milliseconds: 4000));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (_, snapshot) {
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return OverlaySupport(
            child: MaterialApp(
              title: 'Savour Deals',
              theme: savourMaterialLightThemeData,
              darkTheme: savourMaterialDarkThemeData,
              debugShowCheckedModeBanner: false,
              home: _handleCurrentScreen(),
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
            )
          );
        }
        return MaterialApp(home: Scaffold());
      },
    );

  }

  Widget _handleCurrentScreen() {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
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
          return MediaQuery(
            child: PhoneAuth(),
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          );
        }
      }
    );
  }

  verifyUser(User user){
    for (var provider in user.providerData){
      if (provider.providerId == "phone"){
        return true;
      }
    }
    FirebaseAuth.instance.signOut();
    return false;
  }
}



