
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/containers/dealCardWidget.dart';
import 'package:savour_deals_flutter/pages/infoPages/vendorPage.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/redemption_model.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:savour_deals_flutter/pages/infoPages/dealPage.dart';

class WalletPageWidget extends StatefulWidget {
  final Deals deals;
  final List<Vendor> vendors;

  WalletPageWidget(this.deals, this.vendors);

  @override
  _WalletPageWidgetState createState() => _WalletPageWidgetState();
}

class _WalletPageWidgetState extends State<WalletPageWidget> with SingleTickerProviderStateMixin{
  //Location variables
  final _locationService = Geolocator();
  Position currentLocation;
  
  int tabIndex = 0;
  TabController _tabController;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  List<Widget> tabs = [Container(),Container()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    initPlatform();
  }

  void initPlatform() async {
    try {
      var serviceStatus = await _locationService.checkGeolocationPermissionStatus();
      print("Service status: $serviceStatus");
      if (serviceStatus == GeolocationStatus.granted) {
        currentLocation = await _locationService.getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
        if (this.mounted){
          setState(() {
            tabs.clear();
            tabs.add(
              FavoritesPageWidget(
                favorites: widget.deals.getFavorites(), 
                location: currentLocation,
              )
            );
            tabs.add(
              RedeemedWidget(
                widget.deals,
                widget.vendors, 
                currentLocation
              )
            );
          });
        }
        _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.high)).listen((Position result) async {
          if (this.mounted){
            setState(() {
              currentLocation = result;
            });
          }
        });
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        print(e.message);
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        print(e.message);
      }
      currentLocation = null;
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("images/Savour_White.png"),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
        brightness: Brightness.dark,
        bottom: Platform.isAndroid? 
        TabBar(
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          labelStyle: TextStyle(fontSize: 25),
          controller: _tabController,
          tabs: <Widget>[
            Text("Favorites"),
            Text("Redeemed"),
          ],
          onTap: (value) {
            setState(() {
              tabIndex = value;
            });
          },
        ):
        PreferredSize(
          preferredSize: Size(double.infinity, 45.0),
            child: Padding(
              padding: EdgeInsets.only(top: 5.0,bottom: 10.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 15.0,
                  ),
                  Expanded(
                    child: CupertinoSegmentedControl(
                      borderColor: Colors.white,
                      pressedColor: Colors.white.withOpacity(0.5),
                      unselectedColor: (theme.brightness == Brightness.light) ? 
                        theme.primaryColor: 
                          theme.bottomAppBarColor,
                      selectedColor: Colors.white,
                      groupValue: tabIndex,
                      onValueChanged: (value){
                        setState(() {
                          tabIndex = value;
                        });
                      },
                      children: <int, Widget>{
                        0: Text("Favorites"),
                        1: Text("Redeemed"),
                      },
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),                
                ],
              ),
            ),
          ), 
      ),
      body: (currentLocation == null)? 
        Center(child: PlatformCircularProgressIndicator()):
          tabs[tabIndex],
    );
  }
}

class FavoritesPageWidget extends StatefulWidget {
  final List<Deal> favorites;
  final Position location;

  const FavoritesPageWidget({Key key, @required this.favorites, @required this.location}) : super(key: key);

  @override
  _FavoritesPageWidgetState createState() => _FavoritesPageWidgetState();
}

class _FavoritesPageWidgetState extends State<FavoritesPageWidget> {
  List<Deal> favorites;

  @override
  void initState() {
    super.initState();
    favorites = widget.favorites;
  }

  @override
  Widget build(BuildContext context) {
    if (favorites.length > 0){
      return ListView.builder(
        padding: EdgeInsets.all(0.0),
        physics: const AlwaysScrollableScrollPhysics (),
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              print(favorites[position].key + " clicked");
              Navigator.push(
                context,
                platformPageRoute(
                  builder: (context) => DealPageWidget(
                    deal: favorites[position], 
                    location: widget.location
                  ),
                ),
              );
            },
            child: getCard(favorites[position])
          );
        },
        itemCount: favorites.length,
      );
    }
    return Center(child: Text("No favorites to show!"));
  }

  Widget getCard(Deal deal){
    if (deal.isLive()){
      return DealCard(
        deal: deal, 
        location: widget.location, 
        type: DealCardType.large,
        onFavoriteChanged: removeFavoriteAndRefresh,
      );
    }
    return Container();
  }

  void removeFavoriteAndRefresh(String dealID, bool favorited){
    // TODO: This should be changed when we redo the data handling of the app
    if(favorited == false){
      setState(() {
        favorites.removeWhere((deal) => deal.key == dealID);
      });
    }
  }
}

class RedeemedWidget extends StatefulWidget {
  final Deals deals;
  final List<Vendor> vendors;
  final Position location;

  RedeemedWidget(this.deals, this.vendors, this.location);

  _RedeemedWidgetState createState() => _RedeemedWidgetState();
}

class _RedeemedWidgetState extends State<RedeemedWidget> {
  //database variables 
  DatabaseReference redemptionRef = FirebaseDatabase().reference().child("Redemptions");
  FirebaseUser user;
  List<Redemption> redemptions = [];
  bool loaded = false;

  //Declare contextual variables
  ThemeData theme;

  Deals deals;
  List<Vendor> vendors = [];

  @override
  void initState() {
    super.initState();
    deals = widget.deals;
    vendors = widget.vendors;
    init();
  }

  void init() async {
    user = await FirebaseAuth.instance.currentUser();
    redemptionRef.orderByChild("user_id").equalTo(user.uid).onValue.listen((datasnapshot) {
      if (this.mounted && datasnapshot.snapshot.value != null) {
        Map<String, dynamic> redemptionData = new Map<String, dynamic>.from(datasnapshot.snapshot.value);
        redemptionData.forEach((key,data) async {
          var newRedemption = Redemption.fromMap(key,data);
          if (newRedemption.type == "deal"){
            var rdeal = await getDeal(newRedemption.dealID);
            newRedemption.setDeal(rdeal);
            setState(() {
              redemptions.add(newRedemption);
              redemptions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            });
          }else{
            var rvendor = await getVendor(newRedemption.vendorID);
            newRedemption.setVendor(rvendor);
            setState(() {
              redemptions.add(newRedemption);
              redemptions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            });
          }
        });
      }
    });
  }

  Future<Deal> getDeal(String dealID) async {
    if(!deals.containsDeal(dealID)){
      return await FirebaseDatabase().reference().child("Deals").child(dealID).once().then((dealSnap) async {
        var newVendor;
        newVendor = await getVendor(dealSnap.value["vendor_id"]);        
        var newDeal = Deal.fromSnapshot(dealSnap, newVendor, user.uid);
        deals.addDeal(newDeal);//save it for future use
        return newDeal;
      });
    }
    //If the deal is already here, send it back
    return deals.getDealByKey(dealID);
  }

  Future<Vendor> getVendor(String vendorID) async {
    if(vendors.indexWhere((vendor) => vendor.key == vendorID) < 0){
      return await FirebaseDatabase().reference().child("Vendors").child(vendorID).once().then((vendorSnap) {
        var newVendor = Vendor.fromSnapshot(vendorSnap, widget.location.latitude, widget.location.longitude);
        vendors.add(newVendor);
        return newVendor;//save it for future use
      });
    }
    //If the vendor is already here, send it back
    return vendors.firstWhere((vendor) => vendor.key == vendorID);
  }



  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    if (redemptions.length > 0){
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics (),
        padding: EdgeInsets.only(top: 10.0),
        itemBuilder: (context, position) {
          if(position == 0){
            int total = 0;
            redemptions.forEach((r)=>{
              if (r.isDealRedemption()){
                total += r.deal.value
              }
            });
            return Text(
              "Total Estimated Savings: \$" + total.toString(), 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            );
          }
          return Container(
            height: 100,
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
              leading: CircleAvatar(
                backgroundColor: theme.primaryColor,
                backgroundImage: AdvancedNetworkImage(
                  redemptions[position-1].redemptionPhoto,
                  retryDuration: Duration(milliseconds: 1),
                  fallbackAssetImage: 'images/glass-and-fork.png',
                ),
              ),
              title: Text(
                redemptions[position-1].isDealRedemption()?
                  "You redeemed a deal from " + redemptions[position-1].deal.vendorName : 
                    "You checked in at " + redemptions[position-1].vendor.name
              ),
              trailing: Text(timeago.format(DateTime.fromMillisecondsSinceEpoch(-1*redemptions[position-1].timestamp*1000), allowFromNow: true)),
              onTap: (){
                if(redemptions[position-1].isDealRedemption()){
                  Navigator.push(context,
                    platformPageRoute(
                      builder: (BuildContext context) {
                        return DealPageWidget(
                          deal: redemptions[position-1].deal, 
                          location: widget.location
                        );
                      },
                    )
                  );
                }else{
                  Navigator.push(context,
                    platformPageRoute(
                      builder: (BuildContext context) {
                        return VendorPageWidget(redemptions[position-1].vendor, widget.location);
                      },
                    )
                  );
                }
              },
            ),
          );
        },
        itemCount: redemptions.length+1,
      );
    }
    return Center(
      child: Text("No Redemptions.\nRedeem deals to start saving!", textAlign: TextAlign.center,),
    );
  }
}