import 'dart:async';
import 'dart:io';

//TODO: When data handling is restructured, setup local notifications

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:savour_deals_flutter/pages/loginPages/onboardingPage.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/tabPages/tablib.dart';
import 'package:savour_deals_flutter/utils.dart';

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
  bool onboardFinished = false;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  // int lastNearbyNotificationTime;
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  List<Widget> _children = [
    DealsPageWidget(),
    VendorsPageWidget(),
    AccountPageWidget(),
  ];


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _sendCurrentTabToAnalytics(0);
    //Init app rating 
    RateMyApp rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 0,
      minLaunches: 0,
      remindDays: 7,
      remindLaunches: 10,
      googlePlayIdentifier: 'com.CP.Savour',
      appStoreIdentifier: '1294994353'
    );
    rateMyApp.init();

    WidgetsBinding.instance.addObserver(this);
    var newState = await LocationPermissions().checkPermissionStatus();
    if (!mounted) return;
    setState(() {
      locationStatus = newState;
    });
    
    //check if user has used this app before and they have not been prompted for location
    if (locationStatus == PermissionStatus.unknown || (Platform.isAndroid && locationStatus == PermissionStatus.denied)){
      await analytics.logTutorialBegin();
      await Navigator.push(context,
        platformPageRoute(
          settings: RouteSettings(name: "OnboardingPage"),
          context: context,
          builder: (BuildContext context) {
            return new OnboardingPage();
          },
          fullscreenDialog: true
        )
      );
      setState(() {
        onboardFinished = true;//onboarding complete, we can move on and build tabs
      });
      await analytics.logTutorialComplete();
      sleep(const Duration(milliseconds:500));//used so that dismiss doesnt happen and look weird when prompts pop up
    }else{
      setState(() {
        onboardFinished = true;//onboarding has already been done, we can move on and build tabs
      });
    }

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

    //Request Permissions here too incase for some reason we still have not asked 
    LocationPermissions().requestPermissions(permissionLevel: LocationPermissionLevel.locationAlways).then((permissionStatus){
      setState(() {
        locationStatus = permissionStatus;
      });
    });
    if(Platform.isIOS){
      OneSignal.shared.getPermissionSubscriptionState().then((state) async {
        var accepted = false;
        if(!state.permissionStatus.hasPrompted){
          accepted = await OneSignal().promptUserForPushNotificationPermission();
        }else{
          accepted = state.permissionStatus.status == OSNotificationPermission.authorized;
        }
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
      try {
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
      } on PlatformException catch (e) {
        print(e.message);
      }
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
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Image.asset("images/Savour_White.png"),
          ios: (_) => CupertinoNavigationBarData(
            backgroundColor: ColorWithFakeLuminance(appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen, withLightLuminance: true),
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
    }else if (locationStatus == PermissionStatus.granted && onboardFinished == true){
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
            backgroundColor: ColorWithFakeLuminance(appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen, withLightLuminance: true),
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
    return appState.isDark? Colors.white:SavourColorsMaterial.savourGreen;
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
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _sendCurrentTabToAnalytics(index);  
      });
    }
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

  void _sendCurrentTabToAnalytics(int index) {
    var name;
    switch (index) {
      case 0:
        name = 'DealTabPage';
        break;
      case 1:
        name = 'VendorTabPage';
        break;
      case 2:
        name = 'AccountTabPage';
        break;
      default:
        name = 'UnknownTabPage';
    }
    analytics.setCurrentScreen(
      screenName: 'TabsPage/$name',
    );
  }

}
