import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart'
  hide BuildContext;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/containers/dealCardWidget.dart';
import 'package:savour_deals_flutter/containers/vendorCardWidget.dart';
import 'package:savour_deals_flutter/pages/infoPages/dealPage.dart';
import 'package:savour_deals_flutter/pages/infoPages/vendorPage.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:flutter/services.dart';
import 'package:savour_deals_flutter/themes/theme.dart';


class SearchPageWidget extends StatefulWidget {
  final Deals deals;
  final List<Vendor> vendors;
  final Position location;

  SearchPageWidget({this.deals, this.vendors, this.location});

  @override
  _SearchPageWidgetState createState() => _SearchPageWidgetState();
}

class _SearchPageWidgetState extends State<SearchPageWidget> {
  List<Deal> _deals = [];
  List<Deal> _filteredDeals = [];
  List<Vendor> _vendors = [];
  List<Vendor> _filteredVendors = [];
  FirebaseUser user;

  final _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  
  //Location variables
  final _locationService = Geolocator();
  Position currentLocation;

  bool isDealSearch(){
    return (widget.deals != null);
  }

  void initState() {
    super.initState();
    if (widget.deals != null){
      _deals = widget.deals.getAllDeals();
      _filteredDeals = _deals;
    }else{
      _vendors = widget.vendors;
      _filteredVendors = _vendors;
    }
    currentLocation = widget.location;
    initPlatform();
  }

  void initPlatform() async {
    try {
      var serviceStatus = await _locationService.checkGeolocationPermissionStatus();
      if (serviceStatus == GeolocationStatus.granted) {
        _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.high)).listen((Position result) async {
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

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.clear();
      } 
    });
    if (isDealSearch()){
      _controller.addListener(() {
        var text = _controller.text.toLowerCase();
        if (text.trim().length > 0) {
          _filteredDeals = _deals.where((deal) {
            bool containsFilter = false;
            deal.filters.forEach((filter){
              if (filter!=null && filter.toLowerCase().contains(text)){
                containsFilter = true;
              }
            });
            return deal.description.toLowerCase().contains(text) ||
              deal.vendor.name.toLowerCase().contains(text) ||
              containsFilter ;
          }).toList();
          _filteredDeals.sort((a, b) => compareDistanceDeal(a, b));
          setState(() { });
        }else{
          _filteredDeals = _deals;
          _filteredDeals.sort((a, b) => compareDistanceDeal(a, b));
          setState(() {});
        }
      });
    }else{
      _controller.addListener(() {
        var text = _controller.text.toLowerCase();
        if (text.trim().length > 0) {
          _filteredVendors = _vendors.where((vendor) => vendor.name.toLowerCase().contains(text)).toList();
          _filteredVendors.sort((a, b) => compareDistanceVendor(a, b));
          setState(() {});
        }else{
          _filteredVendors = _vendors;
          _filteredVendors.sort((a, b) => compareDistanceVendor(a, b));
          setState(() {});
        }
      });
    }
  }

  int compareDistanceDeal(Deal a, Deal b){
    return a.vendor.distanceMilesFrom(currentLocation.latitude,currentLocation.longitude).compareTo(b.vendor.distanceMilesFrom(currentLocation.latitude,currentLocation.longitude));
  }

  int compareDistanceVendor(Vendor a, Vendor b){
    return a.distanceMilesFrom(currentLocation.latitude,currentLocation.longitude).compareTo(b.distanceMilesFrom(currentLocation.latitude,currentLocation.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchTextField(_controller, _focusNode, isDealSearch()),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Provider.of<AppState>(context).isDark? Theme.of(context).bottomAppBarColor:SavourColorsMaterial.savourGreen,
        brightness: Brightness.dark,
      ),
      body: bodyWidget(),
    );
  }

  Widget bodyWidget(){
    if(isDealSearch()){
      _filteredDeals.sort((a, b) => compareDistanceDeal(a, b));
      return (_filteredDeals.length > 0)? ListView.builder(
        itemCount: _filteredDeals.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              print(_filteredDeals[index].key + " clicked");
              FocusScope.of(context).requestFocus(new FocusNode());
              Navigator.push(
                context,
                platformPageRoute(
                  context: context,
                  settings: RouteSettings(name: "DealPage"),
                  builder: (context) => DealPageWidget(
                    deal: _filteredDeals[index], 
                    location: currentLocation
                  ),
                ),
              );
            },
            child: DealCard(
              deal: _filteredDeals[index], 
              location: currentLocation, 
              type: DealCardType.large
            ),
          );
        },
      ):
      Center (
        child: Text("No Deals Found!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      );    
    }else{
      _filteredVendors.sort((a, b) => compareDistanceVendor(a, b));
      return (_filteredVendors.length > 0)? ListView.builder(
        itemCount: _filteredVendors.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              print(_filteredVendors[index].key + " clicked");
              FocusScope.of(context).requestFocus(new FocusNode());
              Navigator.push(
                context,
                platformPageRoute(
                  settings: RouteSettings(name: "DealPage"),
                  context: context,
                  builder: (context) => VendorPageWidget(_filteredVendors[index], currentLocation),
                ),
              );
            },
            child: VendorCard(_filteredVendors[index], currentLocation),
          );
        },
      ):
      Center (
        child: Text("No Vendors Found!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      );
    }
  }  
}

class DealPopupListItemWidget extends StatelessWidget {
  final Deal item;

  DealPopupListItemWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        item.vendorName + " | " + item.description ,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}

class VendorPopupListItemWidget extends StatelessWidget {
  final Vendor item;

  VendorPopupListItemWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        item.name,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}


class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDealSearch;
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  SearchTextField(this.controller, this.focusNode, this.isDealSearch,);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 0,
        right: 40,
        top: 8,
        bottom: 8,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        cursorColor: Colors.white,
        style: new TextStyle(fontSize: 16, color: Colors.white),
        onSubmitted: (searchText) async {
          await analytics.logSearch(
            searchTerm: searchText,
            origin: this.isDealSearch? 'deal' : 'vendor',
          );
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.5),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.5),
            borderRadius: BorderRadius.all(Radius.circular(5)),
            // borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          suffixIcon: (focusNode.hasFocus)? 
            GestureDetector(
              child: Icon(Icons.cancel, color: Colors.white,),
              onTap: (){
                controller.clear();
                FocusScope.of(context).requestFocus(new FocusNode());
              },
            ):
            Icon(Icons.search, color: Colors.white,),
          border: InputBorder.none,
          hintText: "Search " + ((isDealSearch)? "Deals": "Vendors"),
          hintStyle: TextStyle(fontSize: 16, color: Colors.white),
          contentPadding: EdgeInsets.only(
            left: 16,
            right: 20,
            top: 14,
            // bottom: 5,
          ),
        ),
      ),
    );
  }
}