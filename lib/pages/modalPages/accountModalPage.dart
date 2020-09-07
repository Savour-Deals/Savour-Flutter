import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AccountPageWidget extends StatefulWidget {
  AccountPageWidget();

  @override
  _AccountPageWidgetState createState() => _AccountPageWidgetState();
}

class _AccountPageWidgetState extends State<AccountPageWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  SharedPreferences prefs;

  //Declare contextual variables
  AppState appState;
  NotificationSettings notificationSettings;
  ThemeData theme;

  int totalSavings = 0;

  @override
  void initState() { 
    super.initState();
    user = _auth.currentUser;
    FirebaseDatabase().reference().child("Users").child(user.uid).child("total_savings").onValue.listen((datasnapshot) {
      if (this.mounted){
        setState(() {
          totalSavings = datasnapshot.snapshot.value ?? 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    notificationSettings = Provider.of<NotificationSettings>(context);
    theme = Theme.of(context);
    return Material(child: _bodyWidget());
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
        child: Material(
          child: ListView(
            children: <Widget>[
              Container(height: 50.0,),
              Text(
                "Total Estimated Savings: \$" + totalSavings.toString(), 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Container(height: 50.0,),
              Container(
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.people),
                  ),
                  title: Text("Click to invite more friends!"),
                  contentPadding: EdgeInsets.all(4.0),
                  onTap: () =>{
                    Share.share("Check out Savour to get deals from local restaurants! https://www.savourdeals.com/getsavour")
                  }
                ),
              ),
              Container(
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.mail),
                  ),
                  title: Text("Contact Us"),
                  contentPadding: EdgeInsets.all(4.0),
                  onTap: ()=> _launchURL('https://www.savourdeals.com/contact/'),
                ),
              ),
              Container(
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.notifications_active),
                  ),
                  title: Text("Notifications"),
                  trailing: PlatformSwitch(
                    value: notificationSettings.isNotificationsEnabled,
                    onChanged: (value) {
                      _toggleNotifications();
                    },
                    activeColor: SavourColorsMaterial.savourGreen,
                  ),
                  contentPadding: EdgeInsets.all(4.0),
                ),
              ),
              Container(
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.people),
                  ),
                  title: Text("Learn more about becoming a vendor!"),
                  contentPadding: EdgeInsets.all(4.0),
                  onTap: ()=> _launchURL('https://www.savourdeals.com/vendorsinfo'),
                ),
              ),
            ],
          ),
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
      var user = FirebaseAuth.instance.currentUser;
      notificationSettings.setNotificationsSetting(true);
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