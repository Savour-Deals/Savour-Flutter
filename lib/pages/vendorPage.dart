import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    // ref.child("Users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
    //         //let value = snapshot.value as? NSDictionary
    //         if snapshot.childSnapshot(forPath: "following").hasChild((self.thisVendor.id)!){
    //             self.followString = "Following"
    //         }
    //         else{
    //             self.followString = "Follow"
    //         }
    //         self.reloadTable()
    //     })
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: SavourColorsMaterial.savourGreen,
          leading: CupertinoNavigationBarBackButton(color: Colors.white,),
          brightness: Brightness.dark,
          heroTag: "vendorPage",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          backgroundColor: SavourColorsMaterial.savourGreen,
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
              following: false,
            ),
          ),
          Container(height: 20,),
          AboutWidget(vendor: widget.vendor,)
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
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
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
            color: ThemeData().canvasColor,
          ),
        ),
      ],
    );
  }
}

class VendorButtonRow extends StatefulWidget {
  final String menuURL;
  final String address;
  final bool following;

  VendorButtonRow({
    Key key,
    @required this.menuURL,
    @required this.address,
    @required this.following,
  }) : super(key: key);

  @override
  _VendorButtonRowState createState() => _VendorButtonRowState();
}

class _VendorButtonRowState extends State<VendorButtonRow> {
  bool _following = false;

  @override
  void initState() {
    super.initState();
    _following = widget.following;
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
                Text("Follow", 
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
      setState(() {
        _following = false;
      });
    }else{
      setState(() {
        _following = true;
      });
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