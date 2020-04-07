import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

class Vendors {
  List<Vendor> _vendors = [];
  Position location;

  Vendors();

  Vendors.fromLocation(){
    
  }
}