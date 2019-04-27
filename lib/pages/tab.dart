import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/icons/savour_icons_icons.dart';
import 'package:savour_deals_flutter/pages/tabPages/tablib.dart';
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

class _SavourTabPageState extends State<SavourTabPage> {
  String _emailAddress;
  String _externalUserId;
  bool _enableConsentButton = false;
  String _debugLabelString = "";
  bool _requireConsent = false;


  int _currentIndex = 0;
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
    if (!mounted) return;

    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    // OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    // var settings = {
    //   OSiOSSettings.autoPrompt: false,
    //   OSiOSSettings.promptBeforeOpeningPushUrl: true
    // };

    // OneSignal.shared.setNotificationReceivedHandler((notification) {
    //   this.setState(() {
    //     _debugLabelString =
    //         "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
    //   });
    // });

    // OneSignal.shared
    //     .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    //   this.setState(() {
    //     _debugLabelString =
    //         "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
    //   });
    // });

    // OneSignal.shared
    //     .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
    //   print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    // });

    // OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
    //   print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    // });

    // OneSignal.shared.setEmailSubscriptionObserver(
    //     (OSEmailSubscriptionStateChanges changes) {
    //   print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    // });

    // // NOTE: Replace with your own app ID from https://www.onesignal.com
    // await OneSignal.shared
    //     .init("f1c64902-ab03-4674-95e9-440f7c8f33d0", iOSSettings: settings);

    // OneSignal.shared
    //     .setInFocusDisplayType(OSNotificationDisplayType.notification);

    // bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    // this.setState(() {
    //   _enableConsentButton = requiresConsent;
    // });

    // _handlePromptForPushPermission();
  }

  // void _handleGetTags() {
  //   OneSignal.shared.getTags().then((tags) {
  //     if (tags == null) return;

  //     setState((() {
  //       _debugLabelString = "$tags";
  //     }));
  //   }).catchError((error) {
  //     setState(() {
  //       _debugLabelString = "$error";
  //     });
  //   });
  // }

  // void _handleSendTags() {
  //   print("Sending tags");
  //   OneSignal.shared.sendTag("test2", "val2").then((response) {
  //     print("Successfully sent tags with response: $response");
  //   }).catchError((error) {
  //     print("Encountered an error sending tags: $error");
  //   });
  // }

  // void _handlePromptForPushPermission() {
  //   print("Prompting for Permission");
  //   OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //     print("Accepted permission: $accepted");
  //   });
  // }

  // void _handleGetPermissionSubscriptionState() {
  //   print("Getting permissionSubscriptionState");
  //   OneSignal.shared.getPermissionSubscriptionState().then((status) {
  //     this.setState(() {
  //       _debugLabelString = status.jsonRepresentation();
  //     });
  //   });
  // }

  // void _handleSetEmail() {
  //   if (_emailAddress == null) return;

  //   print("Setting email");

  //   OneSignal.shared.setEmail(email: _emailAddress).whenComplete(() {
  //     print("Successfully set email");
  //   }).catchError((error) {
  //     print("Failed to set email with error: $error");
  //   });
  // }

  // void _handleLogoutEmail() {
  //   print("Logging out of email");
  //   OneSignal.shared.logoutEmail().then((v) {
  //     print("Successfully logged out of email");
  //   }).catchError((error) {
  //     print("Failed to log out of email: $error");
  //   });
  // }

  // void _handleConsent() {
  //   print("Setting consent to true");
  //   OneSignal.shared.consentGranted(true);

  //   print("Setting state");
  //   this.setState(() {
  //     _enableConsentButton = false;
  //   });
  // }

  // void _handleSetLocationShared() {
  //   print("Setting location shared to true");
  //   OneSignal.shared.setLocationShared(true);
  // }

  // void _handleDeleteTag() {
  //   print("Deleting tag");
  //   OneSignal.shared.deleteTag("test2").then((response) {
  //     print("Successfully deleted tags with response $response");
  //   }).catchError((error) {
  //     print("Encountered error deleting tag: $error");
  //   });
  // }

  // void _handleSetExternalUserId() {
  //   print("Setting external user ID");
  //   OneSignal.shared.setExternalUserId(_externalUserId);
  //   this.setState(() {
  //     _debugLabelString = "Set External User ID";
  //   });
  // }

  // void _handleRemoveExternalUserId() {
  //   OneSignal.shared.removeExternalUserId();
  //   this.setState(() {
  //     _debugLabelString = "Removed external user ID";
  //   });
  // }

  // void _handleSendNotification() async {
  //   var status = await OneSignal.shared.getPermissionSubscriptionState();

  //   var playerId = status.subscriptionStatus.userId;

  //   var imgUrlString =
  //       "http://cdn1-www.dogtime.com/assets/uploads/gallery/30-impossibly-cute-puppies/impossibly-cute-puppy-2.jpg";

  //   var notification = OSCreateNotification(
  //       playerIds: [playerId],
  //       content: "this is a test from OneSignal's Flutter SDK",
  //       heading: "Test Notification",
  //       iosAttachments: {"id1": imgUrlString},
  //       bigPicture: imgUrlString,
  //       buttons: [
  //         OSActionButton(text: "test1", id: "id1"),
  //         OSActionButton(text: "test2", id: "id2")
  //       ]);

  //   var response = await OneSignal.shared.postNotification(notification);

  //   this.setState(() {
  //     _debugLabelString = "Sent notification with response: $response";
  //   });
  // }

  // void _handleSendSilentNotification() async {
  //   var status = await OneSignal.shared.getPermissionSubscriptionState();

  //   var playerId = status.subscriptionStatus.userId;

  //   var notification = OSCreateNotification.silentNotification(
  //       playerIds: [playerId], additionalData: {'test': 'value'});

  //   var response = await OneSignal.shared.postNotification(notification);

  //   this.setState(() {
  //     _debugLabelString = "Sent notification with response: $response";
  //   });
  // }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  IndexedStack(
        index: _currentIndex,
        children: _children,
      ),//_children[_currentIndex],
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
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
