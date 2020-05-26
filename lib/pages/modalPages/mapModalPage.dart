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
  FirebaseUser user;
  final _locationService = Geolocator();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _userPosition;
  Position _position;
  Map<String,Marker> _markers = new Map<String,Marker>();
  List<Vendor> sortedVendors;

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
    user = await FirebaseAuth.instance.currentUser();

    GeolocationStatus serviceStatus;
    try {
      serviceStatus = await _locationService.checkGeolocationPermissionStatus();
      if (serviceStatus != null) {
        if (serviceStatus == GeolocationStatus.granted) {
          _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.medium, distanceFilter: 400)).listen((Position result) async {
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
            _onMarkerPressed(markerId);
          }
        ),
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
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        ios: (_) => CupertinoNavigationBarData(
          actionsForegroundColor: Colors.white,
          backgroundColor: ColorWithFakeLuminance(theme.appBarTheme.color, withLightLuminance: true),
          heroTag: "favTab",
          transitionBetweenRoutes: false,
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
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
              padding: const EdgeInsets.only(bottom: 20.0),
              child: PageView.builder(
                key: PageStorageKey('vendorGroup1'), //save deal group's position when scrolling
                controller: PageController(viewportFraction: viewportFrac, initialPage: initialPage),
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
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(target: LatLng(lat, long), zoom: 12)));
    controller.showMarkerInfoWindow(this._markers[id].markerId);
  }

  void _onMarkerPressed(MarkerId markerId) {
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
