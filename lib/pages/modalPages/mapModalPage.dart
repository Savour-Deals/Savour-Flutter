import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

class MapPageWidget extends StatefulWidget {
  final text;
  final List<Vendor> vendors;



  MapPageWidget(this.text, this.vendors);

  @override
  _MapPageWidgetState createState() => _MapPageWidgetState();
}

class _MapPageWidgetState extends State<MapPageWidget> {

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


  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Savour Deals",
          style: whiteTitle,
        ),
        ios: (_) => CupertinoNavigationBarData(
          actionsForegroundColor: Colors.white,
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
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
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(_markers.values),
      ),
    );


  }

  /**
   * loops through vendors and creates a marker for each of them
   */
  void _add() {
    final int markerCount = this.widget.vendors.length;

    for (int i = 0; i < markerCount; i++) {
        MarkerId id = new MarkerId(this.widget.vendors[i].name);
        Marker marker = new Marker(
            markerId: id,
            position: LatLng(
              this.widget.vendors[i].lat,
              this.widget.vendors[i].long,
            )
        );
    }
  }
}
