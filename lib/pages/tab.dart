import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/tabPages/tablib.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SavourTabPage extends StatefulWidget {
  SavourTabPage({Key key, this.uid}) : super(key: key);
  final String title = 'Savour Deals';
  final String uid;

  @override
  _SavourTabPageState createState() => _SavourTabPageState();
}

class _SavourTabPageState extends State<SavourTabPage> with WidgetsBindingObserver{

  int _currentIndex = 0;
  PermissionStatus locationStatus = PermissionStatus.unknown;

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
    WidgetsBinding.instance.addObserver(this);
    var newState = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    setState(() {
      locationStatus = newState;
    });
    if (!mounted) return;

    var user = await FirebaseAuth.instance.currentUser();

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
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
      }else{
        this.setState(() {
          print("Opened notification with no additional data");
        });
      }      
      return;
    });

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    await OneSignal.shared.init("f1c64902-ab03-4674-95e9-440f7c8f33d0", iOSSettings: settings);

    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
      if (user.email != null){
        OneSignal.shared.setEmail();
      }
    });

  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        var newState = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
        setState(() {
          locationStatus = newState;
        });
        break;
      case AppLifecycleState.paused:
        print("Paused");
        break;
      case AppLifecycleState.resumed:
        var newState = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
        setState(() {
          locationStatus = newState;
        });
        print("Resumed");
        break;
      case AppLifecycleState.suspending:
        print("Suspending");
        break;
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return buildTabWidget();
  }

  Widget buildTabWidget(){
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    if (locationStatus == PermissionStatus.unknown){
      PermissionHandler().requestPermissions([PermissionGroup.location]);
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text("Savour Deals",
            style: whiteTitle,
          ),
          ios: (_) => CupertinoNavigationBarData(
            backgroundColor: theme.bottomAppBarColor,//SavourColorsMaterial.savourGreen,
            brightness: Brightness.dark,
          ),
          android: (_) => MaterialAppBarData(
            backgroundColor: theme.bottomAppBarColor,//SavourColorsMaterial.savourGreen,
            brightness: Brightness.dark,
          ),
        ),
        body: Center(
          child: PlatformCircularProgressIndicator(),
        ),
      ); 
    }else if (locationStatus == PermissionStatus.granted){
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
          title: Text("Savour Deals",
            style: whiteTitle,
          ),
          ios: (_) => CupertinoNavigationBarData(
          backgroundColor: theme.bottomAppBarColor,//SavourColorsMaterial.savourGreen,
            brightness: Brightness.dark,
          ),
          android: (_) => MaterialAppBarData(
          backgroundColor: theme.bottomAppBarColor,//SavourColorsMaterial.savourGreen,
            brightness: Brightness.dark,
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
                PermissionHandler().openAppSettings(); 
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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
