import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:savour_deals_flutter/pages/infoPages/vendorPage.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';


class MapPageWidget extends StatefulWidget {
  final text;
  final List<Vendor> vendors;
  CameraPosition cameraPosition;
  MapPageWidget(this.text, this.vendors,this.cameraPosition);

  @override
  _MapPageWidgetState createState() => _MapPageWidgetState();
}

class _MapPageWidgetState extends State<MapPageWidget> {
  FirebaseUser user;
  final _locationService = Geolocator();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _userPosition;
  Map<MarkerId,Marker> _markers = new Map<MarkerId,Marker>();

  void _onMarkerPressed(MarkerId markerId) {
    for (Vendor vendor in this.widget.vendors) {
      if (markerId.value == vendor.name) {
        Navigator.push(
            context,
          platformPageRoute(maintainState: false,
            builder: (context) => new VendorPageWidget(vendor),
          ),
        );
      }
    }
  }

  @override
  void initState()  {
    super.initState();
    initPlatform();
  }

  initPlatform() async {
    user = await FirebaseAuth.instance.currentUser();

    GeolocationStatus serviceStatus;
    try {
      serviceStatus = await _locationService.checkGeolocationPermissionStatus();
    } on Exception catch(e) {
      throw e;
    }
    
    if (serviceStatus != null) {
      if (serviceStatus == GeolocationStatus.granted) {
        _locationService.forceAndroidLocationManager = true;
        Position currentLocation = await _locationService.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
        this._userPosition = new CameraPosition(target: LatLng(currentLocation.latitude,currentLocation.longitude), zoom: 12);
        _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.medium, distanceFilter: 400)).listen((Position result) async {
          this._userPosition = new CameraPosition(target: LatLng(result.latitude,result.longitude), zoom: 12);

        });
      }
    }
    for (Vendor vendor in this.widget.vendors) {
      MarkerId markerId = new MarkerId(vendor.name);
      Marker marker = new Marker(
        markerId: markerId,
        position: LatLng(vendor.lat,vendor.long),
        infoWindow: InfoWindow(
          title: "",
          snippet: vendor.name,
          onTap: () {
            _onMarkerPressed(markerId);
          }
        ),
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
        initialCameraPosition: (_userPosition != null) ? _userPosition: this.widget.cameraPosition,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        markers: Set<Marker>.of(_markers.values),
      ),
    );


  }
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}
