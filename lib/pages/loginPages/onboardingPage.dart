import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:savour_deals_flutter/globals/themes/theme.dart';

class OnboardingPage extends StatefulWidget {

  const OnboardingPage({Key key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  final List<Widget> introWidgetsList = <Widget>[
    PermissionsPage(),
  ];

  PageController controller = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.black,
      body: Material(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            PageView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: introWidgetsList.length,
              onPageChanged: (int page){
                getChangedPageAndMoveBar(page);
              },
              controller: controller,
              itemBuilder: (context,index){
                return introWidgetsList[index];
              },
            ),
            (introWidgetsList.length > 1)?
            Stack(
              alignment: AlignmentDirectional.topStart,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 35),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 0; i < introWidgetsList.length; i++)
                        (i == currentPage)? circleBar(true): circleBar(false),
                    ],
                  ),
                )
              ],
            )
            :
            Container(),
            Container(
              alignment: AlignmentDirectional.bottomEnd,
              margin: EdgeInsets.only(bottom: 35, right: 15),
              child: Visibility(
                visible: (currentPage == introWidgetsList.length - 1),
                child: FloatingActionButton(
                  backgroundColor: SavourColorsMaterial.savourGreen,
                  onPressed: (){
                    //request permissions here incase they didn't press the buttons
                    _requestNotificationPermission();
                    _requestLocationPermission();
                    Navigator.pop(context);
                  },
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(26))
                  ),
                  child: Icon(Icons.arrow_forward, color: Colors.white,),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget circleBar(bool isActive){
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: isActive? 12: 8,
      width: isActive? 12: 8,
      decoration: BoxDecoration(
        color: isActive? SavourColorsMaterial.savourGreen: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  void getChangedPageAndMoveBar(int page){
    setState(() {
      currentPage = page;
    });
  }

  void _requestNotificationPermission(){
    if(Platform.isIOS){
      final fmc = FirebaseMessaging();
      fmc.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: false));
      fmc.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }
  }

  void _requestLocationPermission(){
    LocationPermissions().requestPermissions(permissionLevel: LocationPermissionLevel.locationAlways);
  }
}

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({Key key}) : super(key: key);

  @override
  _PermissionsPageState createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _textMessageAccepted = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    _userRef = FirebaseDatabase().reference().child("Users").child(_auth.currentUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    var notiWidgetList = _notificationPermissionsWidget();
    return PlatformScaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/permissions.jpg"),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.45), BlendMode.srcATop
            ),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text("Permissions",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 45,color:Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Container(padding: EdgeInsets.all(10)),
                  AutoSizeText('We need location services to find all the deals nearby. Click below to give us location access!',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(fontSize: 25, color:Colors.white),
                  ),
                  Container(padding: EdgeInsets.all(10)),
                  PlatformButton(
                    cupertino: (_,__) => CupertinoButtonData(
                      pressedOpacity: 0.7,
                    ),
                    material: (_,__) => MaterialRaisedButtonData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    color: SavourColorsMaterial.savourGreen,
                    child: Text("Location Permissions", style: whiteText),
                    onPressed: () {
                      LocationPermissions().requestPermissions(permissionLevel: LocationPermissionLevel.locationAlways);
                    },
                  ),
                  Container(padding: EdgeInsets.all(10)),
                  AutoSizeText('Would you like to receive text message promotions from Savour Deals?',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(fontSize: 25, color:Colors.white),
                  ),
                  Container(padding: EdgeInsets.all(10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlatformButton(
                        cupertino: (_,__) => CupertinoButtonData(
                          pressedOpacity: 0.7,
                        ),
                        material: (_,__) => MaterialRaisedButtonData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        color: _textMessageAccepted? SavourColorsMaterial.savourGreen : Colors.grey,
                        child: Text("yes", style: whiteText),
                        onPressed: () {
                          _userRef.child("text_acceptance").set(true);
                          setState(() {
                            _textMessageAccepted = true;
                          });
                        },
                      ),
                      Container(padding: EdgeInsets.all(10)),
                      PlatformButton(
                        cupertino: (_,__) => CupertinoButtonData(
                          pressedOpacity: 0.7,
                        ),
                        material: (_,__) => MaterialRaisedButtonData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        color: !_textMessageAccepted? SavourColorsMaterial.savourGreen : Colors.grey,
                        child: Text("no", style: whiteText),
                        onPressed: () {
                          _userRef.child("text_acceptance").set(false);
                          setState(() {
                            _textMessageAccepted = false;
                          });
                        },
                      ),
                    ],
                  ),
                  for (int i = 0; i < notiWidgetList.length; i++)
                    notiWidgetList[i],
                ]
              ),
            ),
          ),
        ),
      )
    );
  }

  List<Widget> _notificationPermissionsWidget(){
    List<Widget> notiWidgets = [];
    if(Platform.isIOS){
      notiWidgets = [
        Container(padding: EdgeInsets.all(15)),
        AutoSizeText('We can send you notifications when your favorite restaurants post a new deal. Click below to allow notifications!',
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(fontSize: 25, color:Colors.white),
        ),
        Container(padding: EdgeInsets.all(10)),
        PlatformButton(
          cupertino: (_,__) => CupertinoButtonData(
            pressedOpacity: 0.7,
          ),
          material: (_,__) => MaterialRaisedButtonData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          color: SavourColorsMaterial.savourGreen,
          child: Text("Notification Permissions", style: whiteText),
          onPressed: () {
            FirebaseMessaging().requestNotificationPermissions(
                const IosNotificationSettings(
                    sound: true, badge: true, alert: true, provisional: false));
            FirebaseMessaging().onIosSettingsRegistered
                .listen((IosNotificationSettings settings) {
              print("Settings registered: $settings");
            });
          },
        )
      ];
    }else{
      notiWidgets = [Container()];
    }
    return notiWidgets;
  }
}