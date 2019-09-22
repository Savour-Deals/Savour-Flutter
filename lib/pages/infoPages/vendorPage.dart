import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorPageWidget extends StatefulWidget {
  final Vendor vendor;
  final Position location;

  VendorPageWidget(this.vendor, this.location);

  @override
  _VendorPageWidgetState createState() => _VendorPageWidgetState();
}

class _VendorPageWidgetState extends State<VendorPageWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  DatabaseReference _userRef;

  //Location variables
  final _locationService = Geolocator();
  Position currentLocation;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  bool following = false;

  @override
  void initState() {
    super.initState();
    currentLocation = widget.location;
    initialize();
  }

  void initialize() async {
    user = await _auth.currentUser();
    _userRef = FirebaseDatabase().reference().child("Users").child(user.uid);
    _userRef.child("following").onValue.listen((data){
      if (data.snapshot != null){
        setState(() {
          following = data.snapshot.value[widget.vendor.key]?? false;
        });        
      }
    });
    try {
      var serviceStatus = await _locationService.checkGeolocationPermissionStatus();
      if (serviceStatus == GeolocationStatus.granted) {//we should have permission but maybe they turned it off since they got here
        _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.best)).listen((Position result) async {
          if (this.mounted){
            setState(() {
              currentLocation = result;
            });
          }
        });
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          leading: CupertinoNavigationBarBackButton(color: Colors.white,),
          brightness: Brightness.dark,
          heroTag: "vendorPage",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          leading: BackButton(color: Colors.white,),
          brightness: Brightness.dark,
          centerTitle: true,
        ),
      ),
      body: ListView(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
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
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                ),
              ),
            ] 
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: VendorButtonRow(
              address: widget.vendor.address,
              menuURL: widget.vendor.menu,
              vendor: widget.vendor,
            ),
          ),
          Container(height: 20,),
          AboutWidget(vendor: widget.vendor,),
          Container(height: 20,),
          (widget.vendor.loyalty.count > -1) ? LoyaltyWidget(vendor: widget.vendor, currentLocation: currentLocation): Container(),
        ],
      ),
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
    return Stack(
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
                child: (_showMore) ? Text("show less"): Text("show more"), 
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
  FirebaseUser user;
  DatabaseReference _userRef;
  DatabaseReference _vendorRef;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    user = await _auth.currentUser();
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
    return Row(
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
              openMap();
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
    );
  }

  _toggleFollow(){
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
                    OneSignal.shared.deleteTag(widget.vendor.key);
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
        OneSignal.shared.deleteTag(widget.vendor.key);
      }
    }else{
      //user is not following, follow this vendor
      _userRef.child("following").child(widget.vendor.key).set(true);
      OneSignal.shared.sendTag(widget.vendor.key, true);
      OneSignal.shared.getPermissionSubscriptionState().then((status){
        if (status.subscriptionStatus.subscribed){
          _vendorRef.child("followers").child(user.uid).set(status.subscriptionStatus.userId);
        }else{
          // if userID is not available (IE the have notifications set off, still log the user as subscribed in firebase)
          _vendorRef.child("followers").child(user.uid).set(user.uid);
        }
      });      
    }
  }

  _launchURL(String url) async {
    if (url != null && url != ""){
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
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

  openMap() async {
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
    var wURL = Uri.encodeFull('https://waze.com/ul?q='+widget.address);
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
  FirebaseUser user;
  DatabaseReference _userRef;
  DatabaseReference _vendorRef;

  int userPoints;
  int pointsGoal;
  double pointPercent;
  int redemptionTime;

  @override
  void initState() {
    super.initState();
    initialize();
    pointsGoal = widget.vendor.loyalty.count;
    if (pointsGoal == 0){
      pointsGoal = 1; //avoid a divide by zero!
    }
  }

  void initialize() async {
    user = await _auth.currentUser();
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

  @override
  Widget build(BuildContext context) {
    var progressWidth = MediaQuery.of(context).size.width*0.85;
    if (userPoints == null){
      //wait until we know how many points they have
      return Container();
    }
    return Column(
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
    );
  }

  _handleLoyaltyPressed(){
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
      displayMessage("Too far away!","Go to location to use their loyalty program!","Okay");
    }
  }

  _loyaltyCheckin(){
    var now = DateTime.now().millisecondsSinceEpoch~/1000; //convert to seconds
    if ((redemptionTime + 10800) < now){//three hours
      //We are ready to checkin! Prompt user with next steps
      //subscribe to notifications
      _userRef.child("following").child(widget.vendor.key).set(true);
      OneSignal.shared.sendTag(widget.vendor.key, true);
      OneSignal.shared.getPermissionSubscriptionState().then((status){
        if (status.subscriptionStatus.subscribed){
          _vendorRef.child("followers").child(user.uid).set(status.subscriptionStatus.userId);
        }else{
          // if userID is not available (IE the have notifications set off, still log the user as subscribed in firebase)
          _vendorRef.child("followers").child(user.uid).set(user.uid);
        }
      });
      setState(() {
        userPoints = userPoints + widget.vendor.loyalty.todaysPoints();
        pointPercent = userPoints.toDouble()/pointsGoal.toDouble();
        if (pointPercent > 1.0){
          pointPercent = 1.0; //clip at 100% filled progress bar
        }    
        _userRef.child("loyalty").child(widget.vendor.key).child("redemptions").update({'count': userPoints,'time': DateTime.now().millisecondsSinceEpoch~/1000});
      });
    }else{
      displayMessage("Too Soon!", "Come back tomorrow to check-in!", "Okay");
    }
  }

  _loyaltyRedeem(){
    var now = DateTime.now().millisecondsSinceEpoch~/1000; //convert to seconds
    if ((redemptionTime + 10800) < now){//three hours
      //We are ready to redeem! Prompt user with next steps
      promptRedeem(); 
    }else{
      displayMessage("Too Soon!", "Come back tomorrow to redeem your points!", "Okay");
    }
  }

  void displayMessage(String title, String message, String buttonText){
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

  void promptRedeem(){
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
}
