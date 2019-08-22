import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/tabPages/tablib.dart';

// import 'package:onesignal/onesignal.dart';
// import 'package:onesignalflutter/onesignalflutter.dart';


class SavourTabPage extends StatefulWidget {
  SavourTabPage({Key key, this.uid}) : super(key: key);
  final String title = 'Savour Deals';
  final String uid;

  @override
  _SavourTabPageState createState() => _SavourTabPageState();
}

class _SavourTabPageState extends State<SavourTabPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin{
  TabController controller;

  int _currentIndex = 0;
  PermissionStatus locationStatus = PermissionStatus.unknown;

  List<Widget> _children = [
    DealsPageWidget("Deals Page"),
    VendorsPageWidget("Vendors Page"),
    AccountPageWidget("Accounts Page"),
  ];

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 3, vsync: this);
    initPlatformState();
  }

  


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    WidgetsBinding.instance.addObserver(this);
    var newState = await LocationPermissions().checkPermissionStatus();
    setState(() {
      locationStatus = newState;
    });
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        var newState = await LocationPermissions().checkPermissionStatus();
        if (this.mounted){
          setState(() {
            locationStatus = newState;
          });
        }
        break;
      case AppLifecycleState.paused:
        print("Paused");
        break;
      case AppLifecycleState.resumed:
        var newState = await LocationPermissions().checkPermissionStatus();
        if (this.mounted){
          setState(() {
            locationStatus = newState;
          });
        }
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
    if (locationStatus == PermissionStatus.unknown){
      LocationPermissions().requestPermissions(permissionLevel: LocationPermissionLevel.locationAlways);
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text("Savour Deals"),
          ios: (_) => CupertinoNavigationBarData(
            backgroundColor: Theme.of(context).bottomAppBarColor,//SavourColorsMaterial.savourGreen,
            brightness: Brightness.dark,
          ),
          android: (_) => MaterialAppBarData(
            backgroundColor: Theme.of(context).bottomAppBarColor,//SavourColorsMaterial.savourGreen,
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
            backgroundColor: Theme.of(context).bottomAppBarColor.withOpacity(1),//SavourColorsMaterial.savourGreen,
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
          backgroundColor: Theme.of(context).bottomAppBarColor,//SavourColorsMaterial.savourGreen,
            brightness: Brightness.dark,
          ),
          android: (_) => MaterialAppBarData(
          backgroundColor: Theme.of(context).bottomAppBarColor,//SavourColorsMaterial.savourGreen,
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
                "We need your location to find all the deals nearby. Click the button below to enable location in settings.", 
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
    return MyInheritedWidget.of(context).data.isDark? Theme.of(context).accentColor:SavourColorsMaterial.savourGreen;

  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
