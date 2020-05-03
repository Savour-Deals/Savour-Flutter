import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';

class VendorsApiProvider {
  final DatabaseReference _vendorRef = FirebaseDatabase().reference().child("Vendors");
  final _geo = Geofire();
  final StreamController _geoController = StreamController();
  Stream _geoStream;
  final StreamController<Vendors> _vendorController = StreamController<Vendors>();
  Stream<Vendors> vendorStream;
  final Vendors _vendors;

  Map<String, VendorCacheItem> _vendorMap = {};

  bool _equals(dynamic p, dynamic n) {
    return p["key"] == n["key"];
  }

  VendorsApiProvider(this._vendors){
    _geo.initialize("Vendors_Location");
    vendorStream = _vendorController.stream.asBroadcastStream();
    _geoStream = _geoController.stream;
    _geoStream.distinct(_equals).listen((vendorData) async {
      final String id = vendorData["key"];
      final double lat = vendorData["lat"];
      final double long = vendorData["long"];
      if (_vendorMap.containsKey(id) && DateTime.now().difference(_vendorMap[id].timestamp).inHours < 5){
        //nothing changed but still refresh stream
        _vendorController.add(_vendors);
      }else{
        if (_vendorMap.containsKey(id)){
          //clear cache and vendor object of the expired vendor
          _vendors.removeVendor(_vendorMap[id].vendor);
          _vendorMap.remove(id);
        }
        //only go to DB if we don't have this vendor and cache has not expired
        final newVendor = await _vendorRef.child(id).once().then((snap) {
          return Vendor.fromSnapshot(snap, lat, long);//save it for future use
        });
        _vendorMap[vendorData["key"]] = VendorCacheItem(newVendor, DateTime.now());
        _vendors.addVendor(newVendor);
        _vendorController.add(_vendors);
      }

    });
    _geo.onObserveReady.listen((_) {
      // this.initialized = true;
    });
    _geo.onKeyEntered.listen((data){
      _geoController.add(data);
    });
    _geo.onKeyExited.listen((data){
      _vendors.removeVendor(_vendorMap.remove(data["key"]).vendor);
      _vendorController.add(_vendors);
    });
  }

  void queryByLocation(Position location) {
    // if(_vendors.location ==  null){
      _vendors.setLocation(location);
      _geo.queryAtLocation(location.latitude, location.longitude, 800.0);//kick off geoquery
    // }
  }

  void updateLocation(Position location) {
    _vendors.setLocation(location);
    _geo.updateLocation(location.latitude, location.longitude, 800.0);//kick off geoquery
            _vendorController.add(_vendors);

  }
}

class VendorCacheItem {
  final Vendor vendor;
  final DateTime timestamp;

  VendorCacheItem(this.vendor, this.timestamp);
}