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
  Stream<Vendors> _vendorStream;
  final Vendors _vendors = Vendors();

  Map<String, VendorCacheItem> _vendorMap = {};

  bool _equals(dynamic p, dynamic n) {
    return p["key"] == n["key"];
  }

  VendorsApiProvider(){
    _geo.initialize("Vendors_Location");
    _vendorStream = _vendorController.stream;
    _geoStream = _geoController.stream;
    _geoStream.distinct(_equals).listen((vendorData) async {
      final Vendor newVendor = await _getVendor(vendorData["key"], vendorData["lat"], vendorData["long"]);
      _vendorMap[vendorData["key"]] = VendorCacheItem(newVendor, DateTime.now());
      _vendors.addVendor(newVendor);
      _vendorController.add(_vendors);
    });
    _geo.onKeyEntered.listen((data){
      _geoController.add(data);
    });
    _geo.onKeyExited.listen((data){
      _vendors.removeVendor(_vendorMap.remove(data["key"]).vendor);
      _vendorController.add(_vendors);
    });
  }

  Stream<Vendors> vendorStreamByLocation(Position location) {
    _vendors.setLocation(location);
    _geo.queryAtLocation(location.latitude, location.longitude, 800.0);//kick off geoquery
    return _vendorStream;
  }

  Future<Vendor> _getVendor(String id, double lat, double long) async {
    if (_vendorMap.containsKey(id) && DateTime.now().difference(_vendorMap[id].timestamp).inHours < 5){
      return _vendorMap[id].vendor;
    }
    //only go to DB if we don't have this vendor and cache has not expired
    return await _vendorRef.child(id).once().then((snap) {
      return Vendor.fromSnapshot(snap, lat, long);//save it for future use
    });
  }
}

class VendorCacheItem {
  final Vendor vendor;
  final DateTime timestamp;

  VendorCacheItem(this.vendor, this.timestamp);
}