import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

class Vendors {
  List<Vendor> _vendors = [];
  Map<String, Vendor> _vendorMap = {};
  int _count = 0;
  Position _location;
  bool _isLoading = true;

  Vendors();

  void addVendor(Vendor newVendor){
    _vendors.add(newVendor);
    _vendorMap[newVendor.key] = newVendor;
    _count++;
  }

  void removeVendor(Vendor vendor){
    _vendors.removeWhere((v) => v.key == vendor.key);
    _vendorMap.remove(vendor.key);
    _count--;
  }

  int _compareDistance(Vendor a, Vendor b){
    return a.distanceMilesFrom(_location.latitude, _location.longitude).compareTo(b.distanceMilesFrom(_location.latitude, _location.longitude));
  }

  Vendor getVendorByKey(String key){
    return _vendorMap[key];
  }

  List<Vendor> getVendorList(){
    //sorted by location
    _vendors.sort((a, b) => _compareDistance(a, b));
    return _vendors;
  }

  void setLocation(Position location){
    _location = location;
  }

  void doneLoading(){
    this._isLoading = false;
  }

  int get count => _count;

  bool get isLoading => _isLoading;

  Position get location => _location;
}