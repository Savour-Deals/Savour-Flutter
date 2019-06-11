import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
  final bool _requireConsent = true;


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
      return Scaffold(
        appBar: AppBar(
          title: Text("Savour Deals",
            style: whiteTitle,
          ),
          brightness: Brightness.dark,
          backgroundColor: SavourColorsMaterial.savourGreen,
        ),
        body: Center(
          child: PlatformCircularProgressIndicator(),
        ),
      ); 
    }else if (locationStatus == PermissionStatus.granted){
      return Scaffold(
        body: IndexedStack(
            index: _currentIndex,
            children: _children,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped, 
          currentIndex: _currentIndex, // this will be set when a new tab is tapped
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(SavourIcons.icons8_price_tag_2,
                color: savourMaterialThemeData.primaryColor,
              ),
              activeIcon: Icon(SavourIcons.icons8_price_tag_filled,
                color: savourMaterialThemeData.primaryColor,
              ),
              title: Text('Deals',
                style: TextStyle(color: savourMaterialThemeData.primaryColor),
              )
            ),
            BottomNavigationBarItem(
              icon: Icon(SavourIcons.icons8_like_2,
                color: savourMaterialThemeData.primaryColor,
              ),
              activeIcon: Icon(SavourIcons.filled_heart,
                color: savourMaterialThemeData.primaryColor,
              ),
              title: Text('Favorites',
                style: TextStyle(color: savourMaterialThemeData.primaryColor),
              )
            ),
            BottomNavigationBarItem(
              icon: Icon(SavourIcons.icons8_small_business,
                color: savourMaterialThemeData.primaryColor,
              ),
              activeIcon: Icon(SavourIcons.icons8_small_business_filled,
                color: savourMaterialThemeData.primaryColor,
              ),
              title: Text('Vendors',
                style: TextStyle(color: savourMaterialThemeData.primaryColor),
              )
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(SavourIcons.),
            //   activeIcon: Icon(SavourIcons.,
              //   color: savourMaterialThemeData.primaryColor,
              // ),
            //   title: Text('Referral',
              //   style: TextStyle(color: Colors.black),
              // )
            // ),
            BottomNavigationBarItem(
              icon: Icon(SavourIcons.icons8_user_male_circle,
                color: savourMaterialThemeData.primaryColor,
              ),
              activeIcon: Icon(SavourIcons.icons8_user_male_circle_filled,
                color: savourMaterialThemeData.primaryColor,
              ),
              title: Text('Account',
                style: TextStyle(color: savourMaterialThemeData.primaryColor),
              )
            )
          ],
        ),
      );
    }else{
      return Scaffold(
        appBar: AppBar(
          title: Text("Savour Deals",
            style: whiteTitle,
          ),
          brightness: Brightness.dark,
          backgroundColor: SavourColorsMaterial.savourGreen,
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
            FlatButton(
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

  void _showDialog(sf, ho) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(sf.toString()),
          content: new Text(ho.toString()),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
