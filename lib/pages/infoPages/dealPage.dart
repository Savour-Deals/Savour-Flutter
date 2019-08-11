import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/pulsator.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/infoPages/vendorPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';




class DealPageWidget extends StatefulWidget {
  final Deal deal;
  final Position location;

  DealPageWidget(this.deal, this.location);

  @override
  _DealPageWidgetState createState() => _DealPageWidgetState();
}

class _DealPageWidgetState extends State<DealPageWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Timer _timer;
  int _start = 0;
  String timerString= "";
  DatabaseReference redemptionRef;

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
    var user = await FirebaseAuth.instance.currentUser();
    redemptionRef = FirebaseDatabase().reference().child("Deals").child(widget.deal.key).child("redeemed").child(user.uid);
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
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        ios: (_) => CupertinoNavigationBarData(
          leading: CupertinoNavigationBarBackButton(color: Colors.white,),
          backgroundColor: MyInheritedWidget.of(context).data.isDark? Theme.of(context).bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
          heroTag: "dealPage",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          backgroundColor: MyInheritedWidget.of(context).data.isDark? Theme.of(context).bottomAppBarColor:SavourColorsMaterial.savourGreen,
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
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                widget.deal.description, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0), 
                textAlign: TextAlign.center,
              ),
            ),
            Stack(
              overflow: Overflow.visible,
              alignment: AlignmentDirectional.center,
              children: <Widget>[ 
                new CustomPaint(
                  painter: new SpritePainter(_controller, 
                    (!widget.deal.isActive()) ? Colors.red : (widget.deal.redeemed && ((DateTime.now().millisecondsSinceEpoch~/1000) - widget.deal.redeemedTime~/1000 >= 1800)) ? Colors.red : SavourColorsMaterial.savourGreen,
                  ),
                  child: new SizedBox(
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
                        builder: (context) => VendorPageWidget(widget.deal.vendor)
                      ),
                    );
                  },
                ),
              ),
            ),
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
    // Android
    var url =  Uri.encodeFull('geo:'+widget.deal.vendor.address);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // iOS
      var url = Uri.encodeFull('comgooglemaps://?daddr='+widget.deal.vendor.address);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        var url =  Uri.encodeFull('http://maps.apple.com/?q='+widget.deal.vendor.address);
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }
    }
  }

  bool inRange(){
    return (widget.deal.vendor.distanceMilesFrom(widget.location.latitude, widget.location.longitude) < 100.1);
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
            if(inRange()){
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
        // return object of type Dialog
        return PlatformAlertDialog(
          title: new Text("Vendor Approval"),
          content: new Text("This deal is intended for one person only.\n\nShow this message to the vendor to redeem your coupon.\n\nThe deal is not guaranteed if the vendor does not see this message."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Approve", style: TextStyle(color: Colors.green),),
              onPressed: () {
                Navigator.of(context).pop();
                print("Deal " + widget.deal.key + " redeemed!");
                var redemptionTime = widget.deal.redeemedTime = DateTime.now().millisecondsSinceEpoch~/1000;
                redemptionRef.set(redemptionTime);
                setState(() {
                  widget.deal.redeemed = true;
                  widget.deal.redeemedTime = redemptionTime*1000;
                });
              },
            ),
            new FlatButton(
              child: new Text("Not Now", style: TextStyle(color: Colors.red),),
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
          // print(_start);
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
    return Text("For dine in and carry out only. Not redeemable with any other promotions unless otherwise mentioned. This deal is only valid for one person. BOGO free items are for equal or lesser value. This deal has no cash value. You must be 21+ to redeem any alcohol deals",
      style: TextStyle(fontSize: 12.0),
      textAlign: TextAlign.center,
    );
  }
}