import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/pulsator.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/infoPages/vendorPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils.dart';

class DealPageWidget extends StatefulWidget {
  final Deal deal;
  final Position location;
  final bool displayMore;

  DealPageWidget({@required this.deal, @required this.location, this.displayMore = true});

  @override
  _DealPageWidgetState createState() => _DealPageWidgetState();
}

class _DealPageWidgetState extends State<DealPageWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Timer _timer;
  int _start = 0;
  String timerString= "";
  DatabaseReference redemptionRef;
  DatabaseReference userRef;
  DatabaseReference vendorRef;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    initialization();
    _controller = new AnimationController(
      vsync: this,
    );
    _startAnimation();
  }

  void initialization() async{
    user = await FirebaseAuth.instance.currentUser();
    redemptionRef = FirebaseDatabase().reference().child("Deals").child(widget.deal.key).child("redeemed").child(user.uid);
    userRef = FirebaseDatabase().reference().child("Users").child(user.uid);
    vendorRef = FirebaseDatabase().reference().child("Vendors").child(widget.deal.vendor.key);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    if (_timer != null){
      _timer.cancel();
    }
  }

  void _startAnimation() {
    _controller.stop();
    _controller.reset();
    _controller.repeat(
      period: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        ios: (_) => CupertinoNavigationBarData(
          leading: CupertinoNavigationBarBackButton(color: Colors.white,),
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          // brightness: Brightness.dark,
          heroTag: "dealPage",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          leading: BackButton(color: Colors.white,),
          brightness: Brightness.dark,
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text(
                widget.deal.vendor.name, 
                style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal*4),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              subtitle: Text(
                widget.deal.description, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.safeBlockHorizontal*6), 
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            Stack(
              overflow: Overflow.visible,
              alignment: AlignmentDirectional.center,
              children: <Widget>[ 
                CustomPaint(
                  painter: SpritePainter(_controller, 
                    _pulsatorColor(),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height*0.45,
                    height: MediaQuery.of(context).size.height*0.45,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.height*0.3,
                  height: MediaQuery.of(context).size.height*0.3,
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: new AdvancedNetworkImage(
                          widget.deal.photo,
                          useDiskCache: true,
                      ),
                    )
                  )
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                child: (widget.deal.redeemed) ? getTimer() : getDetailsText(),
              ),
            ),
            (widget.displayMore)? 
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity, // match_parent
                  height: MediaQuery.of(context).size.height*0.05,
                  child: FlatButton(
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    color: SavourColorsMaterial.savourGreen,
                    child: Text("See More from " + widget.deal.vendor.name,
                      style: whiteText,
                    ), 
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorPageWidget(widget.deal.vendor, widget.location)
                        ),
                      );
                    },
                  ),
                ),
              )
              : 
              Container(height: MediaQuery.of(context).size.height*0.05,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity, // match_parent
                height: MediaQuery.of(context).size.height*0.05,
                child: redemptionButton()
              ),
            ),
          ]
        ),
      ),
    );
  }

  openMap() async {
    print("Navigation to " + widget.deal.vendor.address + " initiated!");
    Map<String,String> mapURLs = {};
    if(Platform.isIOS){
      var gURL = Uri.encodeFull('comgooglemaps://?daddr='+widget.deal.vendor.address);
      if (await canLaunch(gURL)) {
        mapURLs["Google Maps"] =  gURL;
      }
      var aURl =  Uri.encodeFull('http://maps.apple.com/?q='+widget.deal.vendor.address);
      if (await canLaunch(aURl)) {
        mapURLs["Apple Maps"] =  aURl;
      }
    }else if (Platform.isAndroid){
      // Android
      var gURL =  Uri.encodeFull('geo:'+widget.deal.vendor.address);
      if (await canLaunch(gURL)) {
        mapURLs["Google Maps"] =  gURL;
      }
    }
    var wURL = Uri.encodeFull('https://waze.com/ul?q='+widget.deal.vendor.address);
    if (await canLaunch(wURL)) {
      mapURLs["Waze"] =  wURL;
    }
    List<Widget> mapApps = [];
    if(Platform.isIOS){
      mapURLs.forEach((appName, url) {
        mapApps.add(
          CupertinoActionSheetAction(
            child: Text(appName),
            onPressed: () async {
              await launch(url);
              Navigator.of(context).pop();
            },
          )
        );
      });
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: const Text('Navigate with:'),
          actions: mapApps,
          cancelButton: CupertinoActionSheetAction(            
            child: Text("Cancel", style: TextStyle(color: Colors.red),),
            onPressed: () async {
              Navigator.of(context).pop();
            },          
          ),
        ),
      );
    }else if (Platform.isAndroid){
      mapApps.add(
        ListTile(
          title: new Text("Navigate with:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
        ),
      );
      mapURLs.forEach((appName, url) {
        mapApps.add(
          ListTile(
            title: new Text(appName),
            onTap: () async {
              await launch(url);
            },          
          ),
        );
      });
      mapApps.add(
        ListTile(
          title: Text("Cancel", style: TextStyle(color: Colors.red),),
          onTap: () async {
            Navigator.of(context).pop();
          },
        )
      );
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
              children: mapApps,
            ),
          );
        }
      );
    }
  }

  bool inRange(){
    return (widget.deal.vendor.distanceMilesFrom(widget.location.latitude, widget.location.longitude) < 0.1);//100.1); //Chnage to large radius for testing
  }

  Widget redemptionButton(){
    if (widget.deal.isActive()){
      return FlatButton(
        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
        color: (!inRange() || !widget.deal.isActive()) ? Colors.red : (widget.deal.redeemed && ((DateTime.now().millisecondsSinceEpoch~/1000) - widget.deal.redeemedTime~/1000 >= 1800)) ? Colors.red : SavourColorsMaterial.savourGreen,
        child: Text(
          (inRange()) ? ((widget.deal.redeemed) ? "Deal already Redeemed":"Redeem"):"Go to Location to Redeem",
          style: whiteText,
        ),
        onPressed: () {
          if (!widget.deal.redeemed){
            if (inRange()){
              promptRedemption();
            }else{
              openMap();
            }
          }
        },
      );
    }
    return FlatButton(
      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      color: Colors.red,
      child: Text(
        "Deal Not Active",
        style: whiteText,
      ),
      onPressed: (){
        //Do nothing!
      },
    );
  }

  void promptRedemption(){
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text("Vendor Approval"),
          content: Text("This deal is intended for one person only.\n\nShow this message to the vendor to redeem your coupon.\n\nThe deal is not guaranteed if the vendor does not see this message."),
          actions: <Widget>[
            new PlatformDialogAction(
              child: PlatformText("Approve", style: TextStyle(color: Color.fromARGB(255, 0, 255, 0)),),
              onPressed: () {
                Navigator.of(context).pop();
                print("Deal " + widget.deal.key + " redeemed!");
                var redemptionTime = widget.deal.redeemedTime = DateTime.now().millisecondsSinceEpoch~/1000;
                redemptionRef.set(redemptionTime);

                //notification subscriptions
                userRef.child("following").child(widget.deal.vendor.key).set(true);
                OneSignal.shared.sendTag(widget.deal.vendor.key, true);
                OneSignal.shared.getPermissionSubscriptionState().then((status){
                  if (status.subscriptionStatus.subscribed){
                    vendorRef.child("followers").child(user.uid).set(status.subscriptionStatus.userId);
                  }else{
                    // if userID is not available (IE the have notifications set off, still log the user as subscribed in firebase)
                    vendorRef.child("followers").child(user.uid).set(user.uid);
                  }
                });
                setState(() {
                  widget.deal.redeemed = true;
                  widget.deal.redeemedTime = redemptionTime*1000;
                });
              },
            ),
            PlatformDialogAction(
              child: PlatformText("Not Now", style: TextStyle(color: Colors.red),),
              onPressed: () {
                print("Deal " + widget.deal.key + " redemption canceled.");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _start = (DateTime.now().millisecondsSinceEpoch~/1000) - widget.deal.redeemedTime~/1000;
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(() {
        if (_start > 1800) {
          timerString = "Reedeemed over half an hour ago";
          timer.cancel();
        } else {
          _start = _start + 1;
          var minutes = (_start) ~/ 60 % 60;
          var seconds = (_start) % 60;
          timerString = "Redeemed "+minutes.toString() +" minutes "+ seconds.toString() + " seconds ago";
        }
      })
    );
  }
  var first = true;
  Widget getTimer(){
    if (first){
      first = false;
      startTimer();
    }
    return Text(timerString, style: TextStyle(color: (_timer.isActive) ? Colors.green: Colors.red),);
  }

  Widget getDetailsText(){
    return AutoSizeText("For dine in and carry out only. Not redeemable with any other promotions unless otherwise mentioned. This deal is only valid for one person. BOGO free items are for equal or lesser value. This deal has no cash value. You must be 21+ to redeem any alcohol deals",
      style: TextStyle(fontSize: 12.0),
      minFontSize: 10.0,
      maxFontSize: 20.0,
      maxLines: 3,
      textAlign: TextAlign.center,
    );
  }

  Color _pulsatorColor(){
    if (widget.deal.isActive()){
      if (widget.deal.redeemed){
        if (_start > 1800){
          //deal redeemed over half hour ago
          return Colors.red;
        }else{
          //deal was redeemed less than half hour ago
          return Color.fromARGB(255, 0, 255, 0);
        }
      }else{
        return SavourColorsMaterial.savourGreen;
      }

    }else{
      return Colors.red;
    }
  }
  
}