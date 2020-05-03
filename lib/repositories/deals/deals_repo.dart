import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/repositories/deals/deals_provider.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_provider.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';



class DealRepository {
  final DealsApiProvider _dealsApiProvider; 
  final VendorsApiProvider _vendorsApiProvider; 


  DealRepository(this._dealsApiProvider, this._vendorsApiProvider);

  void getDealsForLocation(Position location) {
    _dealsApiProvider.updateLocation(location);
    _vendorsApiProvider.vendorStream.listen((vendors) => processVendors(vendors));

    _vendorsApiProvider.queryByLocation(location);
  }

  void updateDealsLocation(Position location) => _dealsApiProvider.updateLocation(location);

  void processVendors(Vendors vendors) {
    _dealsApiProvider.vendorsQueried
      .difference(HashSet.from(vendors.getVendorList().map((vendor) => vendor.key).toList()))
      .forEach((removedVendor) {
        _dealsApiProvider.removeDealsForVendor(removedVendor);
      });
    
    vendors.getVendorList().forEach((vendor) {
      if (!_dealsApiProvider.containsDealsFor(vendor)){
        _dealsApiProvider.getDealsForVendor(vendor);
      }
    });
  }

  Stream<Vendors> getVendorStream() => _vendorsApiProvider.vendorStream;
  Stream<Deals> getDealsStream() => _dealsApiProvider.dealsStream;
}