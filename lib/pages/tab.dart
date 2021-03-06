import 'dart:async';
import 'dart:io';

//TODO: When data handling is restructured, setup local notifications
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:savour_deals_flutter/blocs/deals/deals_bloc.dart';
import 'package:savour_deals_flutter/blocs/vendor_page/vendor_bloc.dart';
import 'package:savour_deals_flutter/containers/custom_title.dart';
import 'package:savour_deals_flutter/pages/loginPages/onboardingPage.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/globals/themes/theme.dart';
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
  final geo = Geofire();
  int vendorsNearby = 0;
  bool onboardFinished = false;

  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  List<Widget> _children;


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _children = [
      BlocProvider<DealsBloc>(
        create: (context) => DealsBloc(),
        child: DealsPageWidget()
      ),
//      BlocProvider<DealsBloc>(
//        create: (context) => DealsBloc(),
//        child: GoldDealsPageWidget()
//      ),
      BlocProvider<VendorBloc>(
        create: (context) => VendorBloc(),
        child: VendorsPageWidget()
      ),
    ];
    
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
      await _analytics.logTutorialBegin();
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
      //recheck permissions
      var newState = await LocationPermissions().checkPermissionStatus();
      setState(() {
        locationStatus = newState;
        Provider.of<NotificationSettings>(context, listen: false)
            .setNotificationsSetting(locationStatus == PermissionStatus.granted);
        onboardFinished = true;//onboarding complete, we can move on and build tabs
      });
      await FirebaseInAppMessaging().setMessagesSuppressed(false);
      await _analytics.logTutorialComplete();
      sleep(const Duration(milliseconds:500));//used so that dismiss doesnt happen and look weird when prompts pop up
    }else{
      setState(() {
        onboardFinished = true;//onboarding has already been done, we can move on and build tabs
      });
    }
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    if(state == AppLifecycleState.resumed){
      try {
        var newState = await LocationPermissions().checkPermissionStatus();
        // setState(() {
          locationStatus = newState;
          Provider.of<NotificationSettings>(context, listen: false)
              .setNotificationsSetting(locationStatus == PermissionStatus.granted);
        // });
        print("Resumed");
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return buildTabWidget(context);
  }

  Widget buildTabWidget(BuildContext context){
    SizeConfig().init(context);
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    if (locationStatus == PermissionStatus.unknown){
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: SavourTitle(),
          cupertino: (_,__) => CupertinoNavigationBarData(
            backgroundColor: ColorWithFakeLuminance(theme.appBarTheme.color, withLightLuminance: true),
            heroTag: "dealTab",
            transitionBetweenRoutes: false,
          ),
          material: (_,__) => MaterialAppBarData(
            elevation: 0.0,
          ),
        ),
        body: Center(
          child: PlatformCircularProgressIndicator(),
        ),
      );
    } else if (locationStatus == PermissionStatus.granted && onboardFinished == true){
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
          cupertino: (_,__) => CupertinoTabBarData(
            backgroundColor: theme.bottomAppBarColor.withOpacity(1),
          ),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('images/tags.png',
                color: theme.accentColor,
                width: 30,
                height: 30,
              ),
              activeIcon: Image.asset('images/tags_filled.png',
                color: theme.accentColor,
                width: 30,
                height: 30,
              ),
              title: Text('Deals',
                style: TextStyle(color: theme.accentColor),
              )
            ),
//            BottomNavigationBarItem(
//              icon: Image.asset('images/dollar.png',
//                color: SavourColorsMaterial.savourGold,
//                width: 30,
//                height: 30,
//              ),
//              activeIcon: Image.asset('images/dollar_filled.png',
//                color: SavourColorsMaterial.savourGold,
//                width: 30,
//                height: 30,
//              ),
//              title: Text('Savour Gold',
//                style: TextStyle(color: SavourColorsMaterial.savourGold),
//              )
//            ),
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
          ],
        ),
      );
    }else{
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Image.asset(
            "images/Savour_White.png",
          ),
          cupertino: (_,__) => CupertinoNavigationBarData(
            backgroundColor: ColorWithFakeLuminance(theme.appBarTheme.color, withLightLuminance: true),
            heroTag: "dealTab",
            transitionBetweenRoutes: false,
          ),
          material: (_,__) => MaterialAppBarData(
            elevation: 0.0,
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
    _analytics.setCurrentScreen(
      screenName: 'TabsPage/$name',
    );
  }

}
