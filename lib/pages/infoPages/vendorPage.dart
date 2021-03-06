import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/blocs/redemption/redemption_bloc.dart';
import 'package:savour_deals_flutter/containers/custom_title.dart';
import 'package:savour_deals_flutter/containers/dealCardWidget.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/globals/themes/theme.dart';
import 'package:savour_deals_flutter/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dealPage.dart';

class VendorPageWidget extends StatefulWidget {
  final Vendor vendor;
  final Position location;

  VendorPageWidget(this.vendor, this.location);

  @override
  _VendorPageWidgetState createState() => _VendorPageWidgetState();
}

class _VendorPageWidgetState extends State<VendorPageWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  DatabaseReference _userRef;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  //Location variables
  LocationPermission serviceStatus;
  Position currentLocation;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  bool following = false;

  Deals deals = Deals();
  DatabaseReference _dealsRef;

  @override
  void initState() {
    super.initState();
    currentLocation = widget.location;
    initialize();
  }

  void initialize() async {
    await analytics.logViewItem(
      itemId: widget.vendor.key,
      itemName: widget.vendor.name,
      itemCategory: 'vendor',
    );
    try {
      serviceStatus = await checkPermission();
      user = await _auth.currentUser;
    } on PlatformException catch (e) {
      print(e.message);
    }

    //setup query paths
    _userRef = FirebaseDatabase().reference().child("Users").child(user.uid);
    _dealsRef = FirebaseDatabase().reference().child("Deals");

    //Check if the user following this vendor
    _userRef.child("following").onValue.listen((data){
      if (data.snapshot != null && data.snapshot.value != null){
        setState(() {
          following = data.snapshot.value[widget.vendor.key]?? false;
        });        
      }
    });

    // get location updates
    getPositionStream().listen((Position result) async {
      if (this.mounted){
        setState(() {
          currentLocation = result;
        });
      }
    });

    // Get all deals from this vendor
    _dealsRef.orderByChild("vendor_id").equalTo(widget.vendor.key).onValue.listen((dealEvent) {
      if (this.mounted && dealEvent.snapshot != null){
        Map<String, dynamic> dealDataMap = new Map<String, dynamic>.from(dealEvent.snapshot.value);
        setState(() {
          dealDataMap.forEach((key,data){
            Deal newDeal = new Deal.fromMap(key, data, widget.vendor, user.uid);
            // newDeal.favorited = favorites.containsKey(newDeal.key);
            deals.addDeal(newDeal);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: SavourTitle(),
        cupertino: (_,__) => CupertinoNavigationBarData(
          backgroundColor: ColorWithFakeLuminance(theme.appBarTheme.color, withLightLuminance: true),
          leading: CupertinoNavigationBarBackButton(color: Colors.white,),
          heroTag: "vendorPage",
          transitionBetweenRoutes: false,
        ),
        material: (_,__) => MaterialAppBarData(
          leading: BackButton(color: Colors.white,),
          centerTitle: true,
        ),
      ),
      body: Material(
        child: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AdvancedNetworkImage(
                          widget.vendor.photo,
                          useDiskCache: true,
                      ),
                    )
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.3,
                  color: Colors.black.withOpacity(0.3),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        widget.vendor.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Text(
                        widget.vendor.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude).toStringAsFixed(1) + " Miles Away", 
                        style: whiteText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ] 
            ),
            VendorButtonRow(
              address: widget.vendor.address,
              menuURL: widget.vendor.menu,
              vendor: widget.vendor,
            ),
            AboutWidget(vendor: widget.vendor,),
            (widget.vendor.loyalty.count > -1) ? LoyaltyWidget(vendor: widget.vendor, currentLocation: currentLocation): Container(),
            _buildCarousel(context, deals.getAllDeals())
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, List<Deal> carouselDeals) {
    if(carouselDeals.length <= 0){
      return Container(
        padding: EdgeInsets.only(left: 15.0),
        width: MediaQuery.of(context).size.width,
        child: Text("No Current Offers", 
          textAlign: TextAlign.left, 
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    var carouselWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 15.0),
          width: carouselWidth,
          child: Text("Current Offers", 
            textAlign: TextAlign.left, 
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: carouselWidth/2.5,
          child: (carouselDeals.length <= 0)? Container():ListView.separated(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (BuildContext context, int index) => SizedBox(width: 10.0,),
            // store this controller in a State to save the carousel scroll position
            controller: PageController(),
            padding: EdgeInsets.only(left: 10.0),
            itemBuilder: (BuildContext context, int item) {
              return GestureDetector(
                onTap: () {
                  print(carouselDeals[item].key + " clicked");
                  Navigator.push(
                    context,
                    platformPageRoute(
                      context: context,
                      settings: RouteSettings(name: "DealPage"),
                      builder: (context) => BlocProvider<RedemptionBloc>(
                        create: (context) => RedemptionBloc(),
                        child: DealPageWidget(
                          dealId: carouselDeals[item].key, 
                          location: currentLocation,
                          displayMore: false,
                        ),
                      ),
                    ),
                  );
                },
                child: DealCard(
                  deal: carouselDeals[item], 
                  location: currentLocation, 
                  type: DealCardType.small,
                  whSize: carouselWidth/2.5,
                ),
              );
            },
            itemCount: carouselDeals.length,  
          ),
        )
      ],
    );
  }
}

class AboutWidget extends StatefulWidget {
  const AboutWidget({
    Key key,
    @required this.vendor,
  }) : super(key: key);

  final Vendor vendor;

  @override
  _AboutWidgetState createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {
  bool _showMore = false;
  var myGroup = AutoSizeGroup();
  var myGroup1 = AutoSizeGroup();


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width:  MediaQuery.of(context).size.width*0.4,
                      child: AutoSizeText("Address", 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        minFontSize: 10.0,
                        maxFontSize: 22.0,
                        maxLines: 1,
                        group: myGroup,
                      ),
                    ),
                    Container(
                      width:  MediaQuery.of(context).size.width*0.4,
                      child: AutoSizeText("Today's Hours", 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        minFontSize: 10.0,
                        maxFontSize: 22.0,
                        maxLines: 1,
                        group: myGroup,
                      ),
                    ),
                  ],
                ),
                Container(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width:  MediaQuery.of(context).size.width*0.4,
                      child: AutoSizeText(widget.vendor.address, 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                        minFontSize: 10.0,
                        maxFontSize: 15.0,
                        maxLines: 2,
                        group: myGroup1,
                      ),
                    ),
                    Container(
                      width:  MediaQuery.of(context).size.width*0.4,
                      child: AutoSizeText(
                        (widget.vendor.todaysHours() == null) ? "Hours not available":widget.vendor.todaysHours(), 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                        minFontSize: 10.0,
                        maxFontSize: 15.0,
                        maxLines: 2,
                        group: myGroup1,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,15.0,0.0,0.0),
                  child: GestureDetector(
                    child: Text(
                      widget.vendor.description, 
                      maxLines: (_showMore) ? 100000 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: SizeConfig.safeBlockVertical*2.2),
                    ),
                    onTap: (){
                      setState(() {
                        _showMore = !_showMore;
                      });
                    },
                  ),
                ),
                FlatButton(
                  child: (_showMore) ? 
                  Text("show less", 
                    style:  TextStyle(color: Theme.of(context).accentColor),
                  ): Text("show more", 
                    style:  TextStyle(color: Theme.of(context).accentColor),
                  ), 
                  onPressed: () {
                    setState(() {
                      _showMore = !_showMore;
                    });
                  },
                ),
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                width: 1.0, color: Color(0xFFFFDFDFDF),
              ),
            ),
          ),
          FractionalTranslation(
            translation: Offset(.5, -0.5), 
            child:Container(
              padding: EdgeInsets.all(2.0),
              child: Text(
                "About",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 25.0),
              ),
              color: theme.scaffoldBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class VendorButtonRow extends StatefulWidget {
  final String menuURL;
  final String address;
  final Vendor vendor;
  VendorButtonRow({
    Key key,
    @required this.menuURL,
    @required this.address,
    @required this.vendor,
  }) : super(key: key);

  @override
  _VendorButtonRowState createState() => _VendorButtonRowState();
}

class _VendorButtonRowState extends State<VendorButtonRow> {
  bool _following = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  DatabaseReference _userRef;
  DatabaseReference _vendorRef;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _userRef = FirebaseDatabase().reference().child("Users").child(user.uid);
    _vendorRef = FirebaseDatabase().reference().child("Vendors").child(widget.vendor.key);
    _userRef.child("following").onValue.listen((data){
      if (data.snapshot != null){
        setState(() {
          _following = data.snapshot.value[widget.vendor.key]?? false;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 28.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ButtonTheme(
            minWidth: MediaQuery.of(context).size.width*0.3,
            height: 80,
            child: FlatButton(
              child: Column(
                children: <Widget>[
                  Icon(Icons.map, color: Colors.white),
                  Container(height: 4.0),
                  Text("Directions", style: TextStyle(color: Colors.white)),
                ],
              ), 
              shape:  RoundedRectangleBorder(borderRadius: new BorderRadius.circular(12.0)),
              onPressed: () {
                _openMap();
              },
              color: SavourColorsMaterial.savourGreen,
            ),
          ),
          ButtonTheme(
            minWidth: MediaQuery.of(context).size.width*0.3,
            height: 80,
            child: FlatButton(
              child: Column(
                children: <Widget>[
                  Icon(
                    (_following) ? Icons.notifications:Icons.notifications_none, 
                    color: Colors.white
                  ),
                  Container(height: 4.0),
                  Text(
                    (_following) ? "Following": "Follow", 
                    style: TextStyle(color: Colors.white)
                  ),
                ],
              ), 
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(12.0)),
              onPressed: () {
                _toggleFollow();
              },
              color: (_following) ? SavourColorsMaterial.savourGreen : Colors.grey,
            ),
          ),
          ButtonTheme(
            minWidth: MediaQuery.of(context).size.width*0.3,
            height: 80,
            child: FlatButton(
              child: Column(
                children: <Widget>[
                  Icon(Icons.fastfood, color: Colors.white),
                  Container(height: 4.0),
                  Text("Menu", 
                    style: TextStyle(color: Colors.white)
                  ),
                ],
              ), 
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(12.0)),
              onPressed: () {
                _launchURL(widget.menuURL);
              },
              color: SavourColorsMaterial.savourGreen,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFollow(){
    if (_following){
      //user is following, unfollow if they are fine losing loyalty points
      if (widget.vendor.loyalty.count > -1){
        showPlatformDialog(
          builder: (BuildContext context) {
            return PlatformAlertDialog(
              title: Text("Notice!"),
              content: Text("By unfollowing this restaurant you will lose all your loyalty check-ins!"),
              actions: <Widget>[
                PlatformDialogAction(
                  child: PlatformText("Unfollow"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _userRef.child("loyalty").child(widget.vendor.key).child("redemptions").remove();
                    _userRef.child("following").child(widget.vendor.key).remove();
                    _vendorRef.child("followers").child(user.uid).remove();
                    // OneSignal.shared.deleteTag(widget.vendor.key);
                  },
                ),
                PlatformDialogAction(
                  child: PlatformText("Cancel", style: TextStyle(color: Colors.red),),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }, context: context,
        );
      }else{
        //no loyalty program for thsi vendor, just unsubscribe
        _userRef.child("loyalty").child(widget.vendor.key).child("redemptions").remove();
        _userRef.child("following").child(widget.vendor.key).remove();
        _vendorRef.child("followers").child(user.uid).remove();
      }
    }else{
      //user is not following, follow this vendor
      _userRef.child("following").child(widget.vendor.key).set(true);
    }
  }

  void _launchURL(String url) async {
    if (url != null && url != ""){
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        showPlatformDialog(
          builder: (BuildContext context) {
            // return object of type Dialog
            return PlatformAlertDialog(
              title: Text("Sorry!"),
              content: Text("Looks like we are having trouble opening this webpage. Please try again later."),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                PlatformDialogAction(
                  child: PlatformText("Okay"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }, context: context,
        );
      }
    }else{
      showPlatformDialog(
        builder: (BuildContext context) {
          // return object of type Dialog
          return PlatformAlertDialog(
            title: Text("Sorry!"),
            content: Text("Looks like this vendor has not yet made their menu avaliable to us! Sorry for the inconvenience."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              PlatformDialogAction(
                child: PlatformText("😢 Okay"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }, context: context,
      );
    }
  }

  void _openMap() async {
    print("Navigation to " + widget.address + " initiated!");
    Map<String,String> mapURLs = {};
    if(Platform.isIOS){
      var gURL = Uri.encodeFull('comgooglemaps://?daddr='+widget.address);
      if (await canLaunch(gURL)) {
        mapURLs["Google Maps"] =  gURL;
      }
      var aURl =  Uri.encodeFull('http://maps.apple.com/?q='+widget.address);
      if (await canLaunch(aURl)) {
        mapURLs["Apple Maps"] =  aURl;
      }
    }else if (Platform.isAndroid){
      // Android
      var gURL =  Uri.encodeFull('geo:'+widget.address);
      if (await canLaunch(gURL)) {
        mapURLs["Google Maps"] =  gURL;
      }
    }
    var wURL = Uri.encodeFull('waze://ul?q='+widget.address);
    if (await canLaunch('waze://')) {
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
      mapApps.add(
        CupertinoActionSheetAction(
          child: Text("Cancel", style: TextStyle(color: Colors.red),),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        )
      );
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: const Text('Navigate with:'),
          actions: mapApps,
        ),
      );
    }else if (Platform.isAndroid){
      mapApps.add(
        ListTile(
          title: Text("Navigate with:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
        ),
      );
      mapURLs.forEach((appName, url) {
        mapApps.add(
          ListTile(
            title: Text(appName),
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
}

class LoyaltyWidget extends StatefulWidget {
  final Vendor vendor;
  final Position currentLocation;

  const LoyaltyWidget({Key key, this.vendor, this.currentLocation}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LoyaltyWidgetState();
}

class _LoyaltyWidgetState extends State<LoyaltyWidget> with SingleTickerProviderStateMixin {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  DatabaseReference _userRef;
  DatabaseReference _vendorRef;

  int userPoints;
  int pointsGoal;
  double pointPercent;
  int redemptionTime;

  @override
  void initState() {
    super.initState();
    pointsGoal = widget.vendor.loyalty.count;
    if (pointsGoal == 0){
      pointsGoal = 1; //avoid a divide by zero!
    }
    user = _auth.currentUser;
    _userRef = FirebaseDatabase().reference().child("Users").child(user.uid);
    _vendorRef = FirebaseDatabase().reference().child("Vendors").child(widget.vendor.key);
    _userRef.child("loyalty").child(widget.vendor.key).child("redemptions").onValue.listen((data){
      if (data.snapshot.value != null){
        setState(() {
          userPoints = data.snapshot.value["count"] ?? 0;
          redemptionTime = data.snapshot.value["time"] ?? 0;
          pointPercent = userPoints.toDouble()/pointsGoal.toDouble();
          if (pointPercent > 1.0){
            pointPercent = 1.0; //clip at 100% filled progress bar
          }
        });
      }else{
        setState(() {
          userPoints = 0;
          redemptionTime = 0;
          pointPercent = userPoints.toDouble()/pointsGoal.toDouble();
        });
      }
    });
  }

  void _initialize() async {

  }

  @override
  Widget build(BuildContext context) {
    var progressWidth = MediaQuery.of(context).size.width*0.85;
    if (userPoints == null){
      //wait until we know how many points they have
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width*0.75,
            height: 50.0,
            child: FlatButton(
              child: (pointPercent < 1.0)? Text("Loyalty Check-in", style: TextStyle(color: Colors.white)):
                Text("Redeem", style: TextStyle(color: Colors.white)),
              shape:  RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25)),
              onPressed: () {
                _handleLoyaltyPressed();
              },
              color: SavourColorsMaterial.savourGreen,
            ),
          ),
          Container(height: 5),
          Column(
            children: (pointPercent < 1.0)? 
              <Widget>[
                Text("Today: +" + widget.vendor.loyalty.todaysPoints().toString(), style: TextStyle(fontSize: SizeConfig.safeBlockVertical*2.2),),
                Container(height: 5),
                Text("Reach your points goal and recieve:", style: TextStyle(fontSize: SizeConfig.safeBlockVertical*2.2),),
                Text(widget.vendor.loyalty.deal, style: TextStyle(fontSize: SizeConfig.safeBlockVertical*2.2),),
              ]:
              <Widget>[
                Text("You're ready to redeem your " + widget.vendor.loyalty.deal, style: TextStyle(fontSize: SizeConfig.safeBlockVertical*2.2),),
              ],
          ),
          Container(height: 5,),
          Stack(
            children: <Widget>[
              Container(
                //Border for progress
                height: 35.0,
                width: progressWidth,
                decoration: new BoxDecoration(
                  color: Color.fromARGB(255, 200, 232, 202),
                  borderRadius: BorderRadius.all(Radius.circular(17.5)),
                  border: Border.all(width: 2.0, color: Color.fromARGB(255, 89, 204, 93)),
                ),
              ),
              Container(
                //Container visually indicating progress
                height: 35.0,
                width: progressWidth*pointPercent,
                decoration: new BoxDecoration(
                  color: Color.fromARGB(255, 89, 204, 93),
                  borderRadius: BorderRadius.all(Radius.circular(17.5)),
                ),
              ),
              Container(
                height: 35.0,
                padding: EdgeInsets.all(7.5),
                width: progressWidth,
                child: AutoSizeText("$userPoints/$pointsGoal", 
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                  minFontSize: 15,
                  maxFontSize: 25,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
              
            ],
          ),
          Container(height: 10,),
        ],
      ),
    );
  }

  void _handleLoyaltyPressed(){
    if (widget.vendor.distanceMilesFrom(widget.currentLocation.latitude, widget.currentLocation.longitude) < 0.2){
      //close enough to continue. Check duration since last checkin.
      if(pointPercent < 1.0){
        //not enough points to redeem, send them to checkin
        _loyaltyCheckin();
      }else{
        // enough points to redeem. Check if they can
        _loyaltyRedeem();
      }
    }else{
      //vendor too far away
      _displayMessage("Too far away!","Go to location to use their loyalty program!","Okay");
    }
  }

  void _loyaltyCheckin() async {
    var now = DateTime.now().millisecondsSinceEpoch~/1000; //convert to seconds
    if ((redemptionTime + 10800) < now){//three hours
      //We are ready to checkin! Prompt user with next steps
      try {
        ScanResult barcode = await BarcodeScanner.scan();
        if (barcode.rawContent == widget.vendor.loyalty.code){
          //Code was correct!
          //subscribe to notifications
          _userRef.child("following").child(widget.vendor.key).set(true);
          setState(() {
            userPoints = userPoints + widget.vendor.loyalty.todaysPoints();
            pointPercent = userPoints.toDouble()/pointsGoal.toDouble();
            if (pointPercent > 1.0){
              pointPercent = 1.0; //clip at 100% filled progress bar
            }    
            _userRef.child("loyalty").child(widget.vendor.key).child("redemptions").update({'count': userPoints,'time': DateTime.now().millisecondsSinceEpoch~/1000});
          });
        }else{
          _displayMessage("Incorrect code!", "The QR code is incorrect. Contact us if you think this is a mistake.", "Okay");
        }
      } on PlatformException catch (e) {
        if (e.code == BarcodeScanner.cameraAccessDenied) {
          _showSettingsDialog();
        }
      } on FormatException{
        // setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
      } catch (e) {
        _displayMessage("An error occured", "Please try again later.", "Okay");
      }
    }else{
      _displayMessage("Too Soon!", "Come back tomorrow to check-in!", "Okay");
    }
  }

  void _loyaltyRedeem(){
    var now = DateTime.now().millisecondsSinceEpoch~/1000; //convert to seconds
    if ((redemptionTime + 10800) < now){//three hours
      //We are ready to redeem! Prompt user with next steps
      _promptRedeem(); 
    }else{
      _displayMessage("Too Soon!", "Come back tomorrow to redeem your points!", "Okay");
    }
  }

  void _displayMessage(String title, String message, String buttonText){
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            PlatformDialogAction(
              child: PlatformText(buttonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _promptRedeem(){
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text("Confirm Redemption!"),
          content: Text("If you wish to redeem this loyalty deal now, show this message to the server. If you wish to save this deal for later, hit CANCEL."),
          actions: <Widget>[
            PlatformDialogAction(
              child: PlatformText("CANCEL", style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PlatformDialogAction(
              child: PlatformText("Redeem"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  userPoints = userPoints - pointsGoal;
                  pointPercent = userPoints.toDouble()/pointsGoal.toDouble();
                  if (pointPercent > 1.0){
                    pointPercent = 1.0; //clip at 100% filled progress bar
                  }    
                });
                _userRef.child("loyalty")..child(widget.vendor.key).child("redemptions").update({'count': userPoints, 'time': DateTime.now().millisecondsSinceEpoch~/1000});
              },
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text("Camera Permission Needed"),
          content: Text("Please turn on camera access in settings so you can scan the loyalty code!s."),
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
