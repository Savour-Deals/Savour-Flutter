import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;


class MapPageWidget extends StatefulWidget {
  final text;
  final List<Vendor> vendors;

  MapPageWidget(this.text, this.vendors);

  @override
  _MapPageWidgetState createState() => _MapPageWidgetState();
}

class _MapPageWidgetState extends State<MapPageWidget> {
  FirebaseUser user = null;
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId,Marker> _markers = new Map<MarkerId,Marker>();
  

  

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(44.977489, -93.264374),
    zoom: 12.4746,
  );


  void _onMarkerPressed(MarkerId markerId) {

  }


  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);
  @override
  void initState() {
    for (Vendor vendor in this.widget.vendors) {
      vendor;
      vendor.long;
      vendor.lat;

      MarkerId markerId = new MarkerId(vendor.name);
      Marker marker = new Marker(
        markerId: markerId,
        position: LatLng(vendor.lat,vendor.long),
        infoWindow: InfoWindow(title: vendor.name,snippet: vendor.description),
        onTap: () {
          _onMarkerPressed(markerId);
        }
      );

      setState(() {
        _markers[markerId] = marker;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    _auth.currentUser().then((FirebaseUser user) {
      this.user = user;
    });
    
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Savour Deals",
          style: whiteTitle,
        ),
        ios: (_) => CupertinoNavigationBarData(
          actionsForegroundColor: Colors.white,
          backgroundColor: MyInheritedWidget.of(context).data.isDark? Theme.of(context).bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
          heroTag: "favTab",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: MyInheritedWidget.of(context).data.isDark? Theme.of(context).bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
        ),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: _onMapCreated,
        markers: Set<Marker>.of(_markers.values),
      ),
    );


  }
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}
