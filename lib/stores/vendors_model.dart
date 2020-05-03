import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

class Vendors {
  List<Vendor> _vendors = [];
  int _count = 0;
  Position _location;

  Vendors();

  void addVendor(Vendor newVendor){
    print(newVendor.key);
    _vendors.add(newVendor);
    _count++;
  }

  void removeVendor(Vendor vendor){
    _vendors.removeWhere((v) => v.key == vendor.key);
    _count--;
  }

  int _compareDistance(Vendor a, Vendor b){
    return a.distanceMilesFrom(_location.latitude, _location.longitude).compareTo(b.distanceMilesFrom(_location.latitude, _location.longitude));
  }

  List<Vendor> getVendorList(){
    //sorted by location
    _vendors.sort((a, b) => _compareDistance(a, b));
    return _vendors;
  }

  void setLocation(Position location){
    _location = location;
  }

  int get count => _count;

  Position get location => _location;
}