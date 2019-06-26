import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/icons/savour_icons_icons.dart';
import 'package:savour_deals_flutter/pages/tabPages/tablib.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:onesignal/onesignal.dart';
// import 'package:onesignalflutter/onesignalflutter.dart';


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

  List<Widget> _children = [
    DealsPageWidget("Deals Page"),
    FavoritesPageWidget("Favorites Page"),
    VendorsPageWidget("Vendors Page"),
    MapPageWidget("Map Page"),
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
    if (locationStatus == PermissionStatus.unknown){
      PermissionHandler().requestPermissions([PermissionGroup.location]);
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
          // type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(SavourIcons.icons8_price_tag_2,
                color: this.getTabOutlineColor(),
              ),
              activeIcon: Icon(SavourIcons.icons8_price_tag_filled,
                color: this.getTabOutlineColor(),
              ),
              title: Text('Deals',
                style: TextStyle(color: this.getTabOutlineColor()),
              )
            ),
            BottomNavigationBarItem(
              icon: Icon(SavourIcons.icons8_like_2,
                color: this.getTabOutlineColor(),
              ),
              activeIcon: Icon(SavourIcons.filled_heart,
                color: this.getTabOutlineColor(),
              ),
              title: Text('Favorites',
                style: TextStyle(color: this.getTabOutlineColor()),
              )
            ),
            BottomNavigationBarItem(
              icon: Icon(SavourIcons.icons8_small_business,
                color: this.getTabOutlineColor(),
              ),
              activeIcon: Icon(SavourIcons.icons8_small_business_filled,
                color: this.getTabOutlineColor(),
              ),
              title: Text('Vendors',
                style: TextStyle(color: this.getTabOutlineColor()),
              )
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map,
                color: this.getTabOutlineColor(),
              ),
              activeIcon: Icon(Icons.map,
                color: this.getTabOutlineColor(),
              ),
              title: Text('Referral',
                style: TextStyle(color: this.getTabOutlineColor()),
              )
            ),
            BottomNavigationBarItem(
              icon: Icon(SavourIcons.icons8_user_male_circle,
                color: this.getTabOutlineColor(),
              ),
              activeIcon: Icon(SavourIcons.icons8_user_male_circle_filled,
                color: this.getTabOutlineColor(),
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
    return MyInheritedWidget.of(context).data.isDark? Theme.of(context).accentColor:SavourColorsMaterial.savourGreen;

  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
