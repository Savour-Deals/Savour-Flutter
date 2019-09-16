import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorPageWidget extends StatefulWidget {
  final Vendor vendor;

  VendorPageWidget(this.vendor);

  @override
  _VendorPageWidgetState createState() => _VendorPageWidgetState();
}

class _VendorPageWidgetState extends State<VendorPageWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  DatabaseReference _userRef;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  bool following = false;

  @override
  void initState() {
    super.initState();
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
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height*0.3,
                color: Colors.black.withOpacity(0.3),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.vendor.name, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 30.0)),
              )
            ] 
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: VendorButtonRow(
              address: widget.vendor.address,
              menuURL: widget.vendor.menu,
              vendorID: widget.vendor.key,
            ),
          ),
          Container(height: 20,),
          AboutWidget(vendor: widget.vendor,),
          Container(height: 20,),
          (widget.vendor.loyalty.count > -1) ? LoyaltyWidget(vendor: widget.vendor): Container(),
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
                    child: Text("Address", textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    width:  MediaQuery.of(context).size.width*0.4,
                    child: Text("Today's Hours", textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
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
                    child: Text(widget.vendor.address, textAlign: TextAlign.center,style: TextStyle(fontSize: 15)),
                  ),
                  Container(
                    width:  MediaQuery.of(context).size.width*0.4,
                    child: Text(
                      (widget.vendor.todaysHours() == null) ? "Hours not available":widget.vendor.todaysHours(), 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15)
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,15.0,0.0,0.0),
                child: GestureDetector(
                  child: AutoSizeText(
                    widget.vendor.description, 
                    minFontSize: 18.0,
                    maxFontSize: 18.0,
                    maxLines: (_showMore) ? 100000 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: (){
                    setState(() {
                      _showMore = !_showMore;
                    });
                  },
                ),
              ),
              FractionalTranslation(
                translation: Offset(1.4, 0.0),
                child: FlatButton(
                  child: (_showMore) ? Text("show less"): Text("show more"), 
                  onPressed: () {
                    setState(() {
                      _showMore = !_showMore;
                    });
                  },
                ),
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
  final String vendorID;
  VendorButtonRow({
    Key key,
    @required this.menuURL,
    @required this.address,
    @required this.vendorID,
  }) : super(key: key);

  @override
  _VendorButtonRowState createState() => _VendorButtonRowState();
}

class _VendorButtonRowState extends State<VendorButtonRow> {
  bool _following = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    user = await _auth.currentUser();
    _userRef = FirebaseDatabase().reference().child("Users").child(user.uid);
    _userRef.child("following").onValue.listen((data){
      if (data.snapshot != null){
        setState(() {
          _following = data.snapshot.value[widget.vendorID]?? false;
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
    setState(() {
      _following = !_following;
    });
    if (!_following){
      _userRef.child("following").child(widget.vendorID).remove();
      OneSignal.shared.deleteTag(widget.vendorID);
    }else{
      _userRef.child("following").child(widget.vendorID).set(true);
      OneSignal.shared.sendTag(widget.vendorID, true);
    }
  }

  _launchURL(String url) async {
    if (url != null){
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
            title: new Text("Sorry!"),
            content: new Text("Looks like this vendor has not yet made their menu avaliable to us! Sorry for the inconvenience."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("😢 Okay"),
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
    // Android
    var url =  Uri.encodeFull('geo:'+widget.address);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // iOS
      var url = Uri.encodeFull('comgooglemaps://?daddr='+widget.address);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        var url =  Uri.encodeFull('http://maps.apple.com/?q='+widget.address);
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }
    }
  }
}

class LoyaltyWidget extends StatefulWidget {
  final Vendor vendor;

  const LoyaltyWidget({Key key, this.vendor}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LoyaltyWidgetState();
}

class _LoyaltyWidgetState extends State<LoyaltyWidget> with SingleTickerProviderStateMixin {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  DatabaseReference _userRef;

  int userPoints;
  int pointsGoal;
  double pointPercent;

  @override
  void initState() {
    super.initState();
    initialize();
    pointsGoal = widget.vendor.loyalty.count;
  }

  void initialize() async {
    
    user = await _auth.currentUser();
    _userRef = FirebaseDatabase().reference().child("Users").child(user.uid);

    _userRef.child("loyalty").child(widget.vendor.key).child("redemptions").onValue.listen((data){
      if (data.snapshot != null){
        setState(() {
          userPoints = data.snapshot.value["count"] ?? 0;
        });        
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var progressWidth = MediaQuery.of(context).size.width*0.75;
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
            child: Text("Loyalty Check-in", style: TextStyle(color: Colors.white)),
            shape:  RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25)),
            onPressed: () {
            },
            color: SavourColorsMaterial.savourGreen,
          ),
        ),
        Container(height: 5),
        Text("Today: +" + widget.vendor.loyalty.todaysPoints().toString(), style: TextStyle(fontSize: 18),),
        Container(height: 5),
        Text("Reach your points goal and recieve:", style: TextStyle(fontSize: 18),),
        Text(widget.vendor.loyalty.deal, style: TextStyle(fontSize: 18),),
        Container(height: 5,),
        Stack(
          // alignment: ,
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
              width: progressWidth*userPoints.toDouble()/pointsGoal.toDouble(),
              decoration: new BoxDecoration(
                color: Color.fromARGB(255, 89, 204, 93),
                borderRadius: BorderRadius.all(Radius.circular(17.5)),
              ),
            ),
            Container(
              height: 35.0,
              padding: EdgeInsets.all(7.5),
              width: progressWidth,
              child: Text("$userPoints/$pointsGoal", 
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            
          ],
        ),
        Container(height: 10,),
      ],
    );
  }
}
