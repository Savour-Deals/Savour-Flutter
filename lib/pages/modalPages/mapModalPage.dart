import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/containers/custom_title.dart';
import 'package:savour_deals_flutter/containers/vendorCardWidget.dart';
import 'package:savour_deals_flutter/pages/infoPages/vendorPage.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

import '../../utils.dart';


class MapPageWidget extends StatefulWidget {
  final List<Vendor> vendors;
  final Position location;
  MapPageWidget(this.vendors,this.location);

  @override
  _MapPageWidgetState createState() => _MapPageWidgetState();
}

class _MapPageWidgetState extends State<MapPageWidget> {
  User user;
  Completer<GoogleMapController> _controller = Completer();
  PageController _pageController;
  CameraPosition _userPosition;
  Position _position;
  Map<String,Marker> _markers = new Map<String,Marker>();
  List<Vendor> sortedVendors;

  bool _moving = false;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  @override
  void initState()  {
    super.initState();
    this._userPosition = new CameraPosition(target: LatLng(widget.location.latitude, widget.location.longitude), zoom: 12);
    this._position = widget.location;
    this.sortedVendors = widget.vendors;
    this.sortedVendors.sort((a, b) {
      return compareDistance(a,b);
    });
    initPlatform();
  }

  int compareDistance(Vendor a, Vendor b){
    return a.distanceMilesFrom(widget.location.latitude,widget.location.longitude).compareTo(b.distanceMilesFrom(widget.location.latitude,widget.location.longitude));
  }

  initPlatform() async {
    user = FirebaseAuth.instance.currentUser;

    LocationPermission serviceStatus;
    try {
      serviceStatus = await checkPermission();
      if (serviceStatus != null) {
        if (serviceStatus == LocationPermission.always || serviceStatus == LocationPermission.whileInUse) {
          getPositionStream(desiredAccuracy: LocationAccuracy.medium, distanceFilter: 400).listen((Position result) async {
            this._userPosition = new CameraPosition(target: LatLng(result.latitude,result.longitude), zoom: 12);
            this._position = result;
          });
        }
      }
    }  on PlatformException catch (e) {
      print(e.message);
    }

    for (Vendor vendor in this.sortedVendors) {
      MarkerId markerId = new MarkerId(vendor.name);
      Marker marker = new Marker(
        markerId: markerId,
        position: LatLng(vendor.lat,vendor.long),
        infoWindow: new InfoWindow(
          title: vendor.name + "  ⓘ",
          // snippet: vendor.name + "  ⓘ",
          onTap: () {
            _onMarkerWindowPressed(markerId);
          }
        ),
        onTap: () {
          _moving = true;
          _pageController.animateToPage(this.sortedVendors.indexOf(vendor), duration: Duration(milliseconds: 500), curve: Curves.ease).then((_) {
            _moving = false;
          });
        }
      );

      setState(() {
        _markers[vendor.key] = marker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var cardHeight = MediaQuery.of(context).size.height*0.22;
    var viewportFrac = 0.7;
    var initialPage = 0;
    if(MediaQuery.of(context).size.shortestSide > 600){//this is getting into tablet range
      viewportFrac = 0.35; //make a couple fit on the page
      initialPage = 1;
    }
    _pageController = PageController(viewportFraction: viewportFrac, initialPage: initialPage);
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: SavourTitle(),
        cupertino: (_,__) => CupertinoNavigationBarData(
          actionsForegroundColor: Colors.white,
          backgroundColor: ColorWithFakeLuminance(theme.appBarTheme.color, withLightLuminance: true),
          heroTag: "favTab",
          transitionBetweenRoutes: false,
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: cardHeight),
            mapType: MapType.normal,
            initialCameraPosition:_userPosition,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            markers: Set<Marker>.of(_markers.values),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: cardHeight,
              padding: EdgeInsets.only(bottom: 20.0),
              child: PageView.builder(
                key: PageStorageKey('vendorGroup1'), //save deal group's position when scrolling
                controller: _pageController,
                physics: AlwaysScrollableScrollPhysics(),
                onPageChanged: (int item) {
                  this._goToLocation(this.sortedVendors[item].lat, this.sortedVendors[item].long, this.sortedVendors[item].key);
                },
                itemBuilder: (BuildContext context, int item) {
                  return GestureDetector(
                    onTap: () {
                      print(this.sortedVendors[item].key + " clicked");
                      Navigator.push(
                        context,
                        platformPageRoute(
                          context: context,
                          settings: RouteSettings(name: "VendorPage"),
                          builder: (context) => VendorPageWidget(this.sortedVendors[item], this._position)
                        ),
                      );
                    },
                    child: VendorCard(this.sortedVendors[item], this._position),
                  );
                },
                itemCount: this.sortedVendors.length,  
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> _goToLocation(double lat, double long, String id) async {
    if (!_moving){//make sure not to update focused marker if we are already moving
      _moving = true;
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(target: LatLng(lat, long), zoom: 12))).then((_) {
        controller.showMarkerInfoWindow(this._markers[id].markerId);
        _moving = false;
      });
    }
  }

  void _onMarkerWindowPressed(MarkerId markerId) {
    for (Vendor vendor in this.widget.vendors) {
      if (markerId.value == vendor.name) {
        Navigator.push(
          context,
          platformPageRoute(
            settings: RouteSettings(name: "VendorPage"),
            context: context,
            builder: (context) => new VendorPageWidget(vendor, widget.location),
          ),
        );
        return; //if we push one, we are done
      }
    }
  }
}
