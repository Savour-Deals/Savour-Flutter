import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils.dart';


class AccountPageWidget extends StatefulWidget {
  AccountPageWidget();

  @override
  _AccountPageWidgetState createState() => _AccountPageWidgetState();
}

class _AccountPageWidgetState extends State<AccountPageWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  SharedPreferences prefs;

  //Declare contextual variables
  AppState appState;
  NotificationSettings notificationSettings;
  ThemeData theme;

  int totalSavings = 0;

  @override
  void initState() { 
    super.initState();
    initialize();
  }

  void initialize() async {
    _auth.currentUser().then((_userData) {
      setState(() {
        user = _userData;
        FirebaseDatabase().reference().child("Users").child(user.uid).child("total_savings").onValue.listen((datasnapshot) {
          if (this.mounted){
            setState(() {
              totalSavings = datasnapshot.snapshot.value ?? 0; 
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    notificationSettings = Provider.of<NotificationSettings>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        ios: (_) => CupertinoNavigationBarData(
          actionsForegroundColor: Colors.white,
          backgroundColor: ColorWithFakeLuminance(appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen, withLightLuminance: true),
          heroTag: "dealTab",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.0,
          brightness: Brightness.dark,
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
        ),
        trailingActions: <Widget>[
          FlatButton(
            child: Text("Logout", style: TextStyle(color: Colors.red) ),
            color: Colors.transparent,
            onPressed: (){
              _auth.signOut();
            },
          )
        ],
      ),
      body: Material(child: _bodyWidget())
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _bodyWidget(){
    return (user == null) ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center (
            child: PlatformCircularProgressIndicator()
          ),
        ],
      ):Center(
        child: ListView(
          children: <Widget>[
            Container(height: 20.0,),
            Text(
              "Total Estimated Savings: \$" + totalSavings.toString(), 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Container(height: 20.0,),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.people,
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Click to invite more friends!",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                onTap: () =>{
                  Share.share("Check out Savour to get deals from local restaurants! https://www.savourdeals.com/getsavour")
                }
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1))
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.mail,
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Contact Us",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                onTap: ()=> _launchURL('https://www.savourdeals.com/contact/'),
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1))
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications_active,
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Notifications",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
                ),
                trailing: PlatformSwitch(
                  value: notificationSettings.isNotificationsEnabled,
                  onChanged: (value) {
                    _toggleNotifications();
                  },
                  // activeTrackColor: theme.primaryColor, 
                  activeColor: theme.primaryColor,
                ),
                // onTap: () => _toggleNotifications(),
                contentPadding: EdgeInsets.all(4.0),
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1))
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.people,
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Learn more about becoming a vendor!",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                onTap: ()=> _launchURL('https://www.savourdeals.com/vendorsinfo'),
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1), bottom: BorderSide(width: 0.1)),
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.lightbulb_outline,
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Switch to " + (appState.isDark? "light":"dark") + " mode",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                onTap: () {
                  setState(() {
                    appState.setDarkMode(!appState.isDark);
                  });
                },
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1), bottom: BorderSide(width: 0.1)),
              ),
            ),
          ],
        )
      );
  }

  // ImageProvider getPhoto(){
  //   if (user.photoUrl != null){
  //     return AdvancedNetworkImage(
  //         user.photoUrl,
  //         useDiskCache: true,
  //         fallbackAssetImage: "images/login_background.jpg",
  //         retryLimit: 0,
  //     );
  //   }
  //   return AssetImage("images/login_background.jpg");
  // }

  _toggleNotifications() async {
    if(notificationSettings.isNotificationsEnabled){
      _notificationPermissionHandler(false);
    }else{
      if(Platform.isIOS){
        OneSignal.shared.getPermissionSubscriptionState().then((subscriptionState){
          switch (subscriptionState.permissionStatus.status) {
            case OSNotificationPermission.authorized:
              //we have iOS permissions, resubscribe with onesignal
              _notificationPermissionHandler(true);
              break;
            case OSNotificationPermission.denied:
              // User denied previously, prompt them to go to settings
              // Accept/deny handled in tab.dart::didChangeAppLifecycleState
              _showSettingsDialog();
              break;
            default:
            // User was never prompted. WTH man!
              OneSignal.shared.promptUserForPushNotificationPermission().then((accepted){
                print("Accepted permission: $accepted");
                _notificationPermissionHandler(accepted);
              });
          }
        });
      }else{
        print("Accepted permission: Not needed for android");
        _notificationPermissionHandler(true);
      }
    }
  }

  Future _notificationPermissionHandler(bool accepted) async {
    if (accepted){
      print("Notifications turned on!");
      var user = await FirebaseAuth.instance.currentUser();
      Provider.of<NotificationSettings>(context).setNotificationsSetting(true);
      OneSignal.shared.setSubscription(true);
      if (user.email != null){
        OneSignal.shared.setEmail(email: user.email);
      }
    }else{
      print("Notifications turned off!");
      OneSignal.shared.setSubscription(false);
      notificationSettings.setNotificationsSetting(false);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text("Notification Permission Needed"),
          content: Text("Please turn on notifications in settings."),
          actions: <Widget>[
            FlatButton(
              child: Text("Go to Settings"),
              onPressed: () {
                AppSettings.openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Not Now", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}