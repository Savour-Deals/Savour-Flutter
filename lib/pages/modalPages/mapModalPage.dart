import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart'
  hide BuildContext;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/pages/infoPages/vendorPage.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

import '../../utils.dart';


class MapPageWidget extends StatefulWidget {
  final text;
  final List<Vendor> vendors;
  final Position location;
  MapPageWidget(this.text, this.vendors,this.location);

  @override
  _MapPageWidgetState createState() => _MapPageWidgetState();
}

class _MapPageWidgetState extends State<MapPageWidget> {
  FirebaseUser user;
  final _locationService = Geolocator();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _userPosition;
  Map<MarkerId,Marker> _markers = new Map<MarkerId,Marker>();

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  @override
  void initState()  {
    super.initState();
    this._userPosition = new CameraPosition(target: LatLng(widget.location.latitude, widget.location.longitude), zoom: 12);
    initPlatform();
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
          });
        }
      }
    }  on PlatformException catch (e) {
      print(e.message);
    }

    for (Vendor vendor in this.widget.vendors) {
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
        _markers[markerId] = marker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        ios: (_) => CupertinoNavigationBarData(
          actionsForegroundColor: Colors.white,
          backgroundColor: ColorWithFakeLuminance(appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen, withLightLuminance: true),
          heroTag: "favTab",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
        ),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:_userPosition,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        markers: Set<Marker>.of(_markers.values),
      ),
    );


  }
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
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
