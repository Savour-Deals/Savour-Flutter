import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/themes/pulsator.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/vendorPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';



class DealPageWidget extends StatefulWidget {
  final Deal deal;
  final Position location;

  DealPageWidget(this.deal, this.location);

  @override
  _DealPageWidgetState createState() => _DealPageWidgetState();
}

class _DealPageWidgetState extends State<DealPageWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
    );
    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Deal Page",
          style: whiteTitle,
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
                    (!widget.deal.isActive() || widget.deal.redeemed) ? Colors.red : SavourColorsMaterial.savourGreen,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                child: getDetailsText(),
              ),
            ),
            SizedBox(
              width: double.infinity, // match_parent
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
                        builder: (context) => VendorPageWidget(widget.deal.vendor)),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity, // match_parent
              child: redemptionButton()
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
    return (widget.deal.vendor.distanceMilesFrom(widget.location.latitude, widget.location.longitude) < 0.1);
  }

  Widget redemptionButton(){
    if (widget.deal.isActive()){
      return FlatButton(
        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
        color: (inRange()) ? SavourColorsMaterial.savourGreen: Colors.red,
        child: Text(
          (inRange()) ? "Redeem":"Go to Location to Redeem",
          style: whiteText,
        ),
        onPressed: () {
          if(inRange()){
            promptRedemption();
          }else{
            openMap();
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Vendor Approval"),
          content: new Text("This deal is intended for one person only.\n\nShow this message to the vendor to redeem your coupon.\n\nThe deal is not guaranteed if the vendor does not see this message."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Approve"),
              onPressed: () {
                //TODO:Redeem Deal!
                print("Deal " + widget.deal.key + " redeemed!");
              },
            ),
            new FlatButton(
              child: new Text("Not Now"),
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

  Widget getDetailsText(){
    return Text("For dine in and carry out only. Not redeemable with any other promotions unless otherwise mentioned. This deal is only valid for one person. BOGO free items are for equal or lesser value. This deal has no cash value. You must be 21+ to redeem any alcohol deals",
      style: TextStyle(fontSize: 12.0),
      textAlign: TextAlign.center,
    );
  }
}