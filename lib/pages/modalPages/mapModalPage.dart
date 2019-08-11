import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MapPageWidget extends StatefulWidget {
  final text;
  final List<Vendor> vendors;

  MapPageWidget(this.text, this.vendors);

  @override
  _MapPageWidgetState createState() => _MapPageWidgetState();
}

class _MapPageWidgetState extends State<MapPageWidget> {
  FirebaseUser user;
  final _locationService = Geolocator();
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId,Marker> _markers = new Map<MarkerId,Marker>();
  CameraPosition _userPosition;

  void _onMarkerPressed(MarkerId markerId) {

  }

  @override
  void initState() async {
    user = await FirebaseAuth.instance.currentUser();

    GeolocationStatus serviceStatus;
    try {
      serviceStatus = await _locationService.checkGeolocationPermissionStatus();
    } on Exception catch(e) {
      throw e;
    }

    if (serviceStatus != null) {
      if (serviceStatus == GeolocationStatus.granted) {
        Position currentLocation = await _locationService.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
        _userPosition = new CameraPosition(target: LatLng(currentLocation.latitude,currentLocation.longitude));
      }
    }
    for (Vendor vendor in this.widget.vendors) {

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
        initialCameraPosition: _userPosition,
        onMapCreated: _onMapCreated,
        markers: Set<Marker>.of(_markers.values),
      ),
    );


  }
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}
