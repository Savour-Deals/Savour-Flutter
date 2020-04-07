import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

class VendorsApiProvider {
  final DatabaseReference _vendorRef = FirebaseDatabase().reference().child("Vendors");
  final _geo = Geofire();
  StreamController geoController = StreamController();
  Stream geoStream;
  StreamController<List<VendorCacheItem>> vendorController = StreamController<List<VendorCacheItem>>();
  Stream<List<VendorCacheItem>> vendorStream;

  Map<String, VendorCacheItem> vendorMap = {};

  bool equals(dynamic p, dynamic n) {
    return p["key"] == n["key"];
  }

  VendorsApiProvider(){
    _geo.initialize("Vendors_Location");
    vendorStream = vendorController.stream;
    geoStream = geoController.stream;
    geoStream.distinct(equals).listen((vendorData) async {
      vendorMap[vendorData["key"]] = VendorCacheItem(
        await getVendor(vendorData["key"], vendorData["lat"], vendorData["long"]), 
        DateTime.now());
      vendorController.add(vendorMap.values.toList());
    });
    _geo.onKeyEntered.listen((data){
      geoController.add(data);
    });
    _geo.onKeyExited.listen((data){
      vendorMap.remove(data["key"]);
      vendorController.add(vendorMap.values.toList());
    });
  }

  Stream<List<VendorCacheItem>> vendorStreamByLocation(Position location) {
    _geo.queryAtLocation(location.latitude, location.longitude, 800.0);//kick off geoquery
    return vendorStream;
  }

  Future<Vendor> getVendor(String id, double lat, double long) async {
    if (vendorMap.containsKey(id)  && DateTime.now().difference(vendorMap[id].timestamp).inHours < 5){
      return vendorMap["id"].vendor;
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