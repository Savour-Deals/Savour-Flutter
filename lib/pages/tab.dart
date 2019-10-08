import 'dart:async';
import 'dart:io';

//TODO: When data handling is restructured, setup local notifications

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/pages/loginPages/onboardingPage.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/tabPages/tablib.dart';
import '../utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SavourTabPage extends StatefulWidget {
  SavourTabPage({Key key, this.uid}) : super(key: key);
  final String title = 'Savour Deals';
  final String uid;

  @override
  _SavourTabPageState createState() => _SavourTabPageState();
}

class _SavourTabPageState extends State<SavourTabPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin{

  int _currentIndex = 0;
  PermissionStatus locationStatus = PermissionStatus.unknown;
  // final _locationService = Geolocator();
  final geo = Geofire();
  int vendorsNearby = 0;

  SharedPreferences prefs;
  // int lastNearbyNotificationTime;
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  List<Widget> _children = [
    DealsPageWidget("Deals Page"),
    VendorsPageWidget("Vendors Page"),
    AccountPageWidget("Accounts Page"),
  ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    //check if user has used this app before
    // prefs = await SharedPreferences.getInstance();
    // var hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
    // if (!hasOnboarded){
    //   //TODO: Uncomment this when testing of onboarding is done
    //   // prefs.setBool('hasOnboarded', true);
    //   Navigator.push(context,
    //     platformPageRoute(
    //       builder: (BuildContext context) {
    //         return new OnboardingPage();
    //       },
    //       fullscreenDialog: true
    //     )
    //   );
    // }
    
    WidgetsBinding.instance.addObserver(this);
    var newState = await LocationPermissions().checkPermissionStatus();
    if (!mounted) return;
    setState(() {
      locationStatus = newState;
    });

    //setup remote notifications
    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      _notificationHandler(result);
    });

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    await OneSignal.shared.init("f1c64902-ab03-4674-95e9-440f7c8f33d0", iOSSettings: settings);

    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    if(Platform.isIOS){
      OneSignal.shared.promptUserForPushNotificationPermission().then((accepted){
        print("Accepted permission: $accepted");
        _notificationPermissionHandler(accepted);
      });
    }else{
      print("Accepted permission: Not needed for android");
      _notificationPermissionHandler(true);
    }

    // //Setup local notifications
    // prefs = await SharedPreferences.getInstance();
    // lastNearbyNotificationTime = prefs.getInt('lastNearbyNotificationTime') ?? 0;
    // flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // var initializationSettingsAndroid = new AndroidInitializationSettings('icon_logo');
    // var initializationSettingsIOS = new IOSInitializationSettings(
    //     requestAlertPermission: false, //this should be handles by onesignal above
    //     requestBadgePermission: false, //we dont need this
    //     defaultPresentBadge: false,
    // );
    // var initializationSettings = new InitializationSettings(
    //     initializationSettingsAndroid, 
    //     initializationSettingsIOS
    // );
    // flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    //   onSelectNotification: onSelectNotification
    // ); 

    // //setup geofire
    // geo.initialize("Vendors_Location");
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    if(state == AppLifecycleState.resumed){
      var newState = await LocationPermissions().checkPermissionStatus();
      var notificationStatus = await OneSignal.shared.getPermissionSubscriptionState();
      var notificationsEnabled = notificationStatus.permissionStatus.status == OSNotificationPermission.authorized;
      debugPrint("Accepted: $notificationsEnabled");
      if(this.mounted){
        setState(() {
          locationStatus = newState;
          _notificationPermissionHandler(notificationsEnabled);
        });
      }
      print("Resumed");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return buildTabWidget();
  }

  Widget buildTabWidget(){
    SizeConfig().init(context);
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    if (locationStatus == PermissionStatus.unknown){
      LocationPermissions().requestPermissions(permissionLevel: LocationPermissionLevel.locationAlways);
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Image.asset("images/Savour_White.png"),
          ios: (_) => CupertinoNavigationBarData(
            brightness: Brightness.dark,
            backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
            heroTag: "dealTab",
            transitionBetweenRoutes: false,
          ),
          android: (_) => MaterialAppBarData(
            elevation: 0.0,
            brightness: Brightness.light,
            backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          ),
        ),
        body: Center(
          child: PlatformCircularProgressIndicator(),
        ),
      ); 
    }else if (locationStatus == PermissionStatus.granted){
      // _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.medium, distanceFilter: 400)).listen((Position result) async {
      //   geo.queryAtLocation(result.latitude, result.longitude, 0.25);
      //   geo.onKeyEntered.listen((data){
      //     vendorsNearby++;
      //     if (vendorsNearby > 0 && (lastNearbyNotificationTime + Duration(seconds: 50/*days: 1*/).inMilliseconds) <= DateTime.now().millisecondsSinceEpoch){
      //       //We are nearby a ton of vendors and we havent sent a message in a while. 
      //       lastNearbyNotificationTime = DateTime.now().millisecondsSinceEpoch;
      //       sendLocalNotification();
      //     }
      //   });
      //   geo.onKeyExited.listen((data){
      //     vendorsNearby--;
      //   });
      // });
      return PlatformScaffold(
        body: IndexedStack(
            index: _currentIndex,
            children: _children,
        ),
        bottomNavBar: PlatformNavBar(
          currentIndex: _currentIndex,
          itemChanged: onTabTapped,
          ios: (_) => CupertinoTabBarData(
            backgroundColor: theme.bottomAppBarColor.withOpacity(1),//SavourColorsMaterial.savourGreen,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('images/tags.png',
                color: this.getTabOutlineColor(),
                width: 30,
                height: 30,
              ),
              activeIcon: Image.asset('images/tags_filled.png',
                color: this.getTabOutlineColor(),
                width: 30,
                height: 30,
              ),
              title: Text('Deals',
                style: TextStyle(color: this.getTabOutlineColor()),
              )
            ),
            BottomNavigationBarItem(
              icon: Image.asset('images/vendor.png',
                color: this.getTabOutlineColor(),
                width: 30,
                height: 30,
              ),
              activeIcon: Image.asset('images/vendor_filled.png',
                color: this.getTabOutlineColor(),
                width: 30,
                height: 30,
              ),
              title: Text('Vendors',
                style: TextStyle(color: this.getTabOutlineColor()),
              )
            ),
            BottomNavigationBarItem(
              icon: Image.asset('images/user.png',
                color: this.getTabOutlineColor(),
                width: 30,
                height: 30,
              ),
              activeIcon: Image.asset('images/user_filled.png',
                color: this.getTabOutlineColor(),
                width: 30,
                height: 30,
              ),
              title: Text('Account',
                style: TextStyle(color: this.getTabOutlineColor()),
              )
            )
          ],
        ),
      );
    }else{
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Image.asset("images/Savour_White.png"),
          ios: (_) => CupertinoNavigationBarData(
            brightness: Brightness.dark,
            backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
            heroTag: "dealTab",
            transitionBetweenRoutes: false,
          ),
          android: (_) => MaterialAppBarData(
            elevation: 0.0,
            brightness: Brightness.light,
            backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "We need your location to find all the nearby deals. Click the button below to enable location in settings.", 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20,),
              ),
            ),
            PlatformButton(
              child: Text("Go to Settings", style: whiteText,),
              onPressed: (){
                LocationPermissions().openAppSettings(); 
              },
              color: SavourColorsMaterial.savourGreen,
            ),
          ],
        ),
      ); 
    }
  }

  Color getTabOutlineColor(){
    return appState.isDark? theme.accentColor:SavourColorsMaterial.savourGreen;
  }

// The following commented code is for notifications when a user is nearby so many vendors
// To implement this, data handling needs to be refactored 
  // sendLocalNotification() async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'vendorsnearby', 'Nearby Notifications', 'These notifications let you know when lots of restaurants, bars, and other shops are nearby.',
  //     importance: Importance.Max, 
  //     priority: Priority.High, 
  //     ticker: 'ticker'
  //   );
  //   var iOSPlatformChannelSpecifics = IOSNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: false,
  //     presentSound: true,
  //   );
  //   var platformChannelSpecifics = NotificationDetails(
  //       androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  //   debugPrint('Sending local push notification');
  //   await flutterLocalNotificationsPlugin.show(
  //     0, 
  //     "Woah You're Near Some Hot Deals! 😋", 
  //     "Look at all the current deals nearby! 🍴", 
  //     platformChannelSpecifics,
  //   );   
  // }

  // Future onSelectNotification(String payload) async {
  //   if (payload != null) {
  //     debugPrint('notification payload: ' + payload);
  //   }
  //   setState(() {
  //     _currentIndex = 1; //set page to vendor page
  //   });
  // }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future _notificationPermissionHandler(bool accepted) async {
    if (accepted){
      var user = await FirebaseAuth.instance.currentUser();
      Provider.of<NotificationSettings>(context).setNotificationsSetting(true);
      OneSignal.shared.setSubscription(true);
      if (user.email != null){
        OneSignal.shared.setEmail(email: user.email);
      }
    }else{
      Provider.of<NotificationSettings>(context).setNotificationsSetting(false);
      OneSignal.shared.setSubscription(false);
    }
  }

  void _notificationHandler(OSNotificationOpenedResult result){
    if(!mounted) return;
    if(result.notification.payload.additionalData.isNotEmpty){
        if(result.notification.payload.additionalData.containsKey("deal")){
          var dealID = result.notification.payload.additionalData['deal'];
          this.setState(() {
            // print("Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
            print("Opened notification with deal ID: $dealID");
            Provider.of<NotificationData>(context).setNotiDealID(dealID);
          });
        }else{
          this.setState(() {
            var data = result.notification.payload.additionalData;
            print("Opened notification with additional data: $data");
          });
        }
      }//else Opened notification with no additional data
  }
}
