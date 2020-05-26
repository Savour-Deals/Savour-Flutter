import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';
import 'package:savour_deals_flutter/utils.dart' as globals;

class DealRepository {


  DealRepository();

  void getDealsForLocation(Position location) {
    globals.dealsApiProvider.updateLocation(location);
    globals.vendorApiProvider.vendorStream.listen((vendors) => processVendors(vendors));

    globals.vendorApiProvider.queryByLocation(location);
  }

  void updateDealsLocation(Position location) => globals.dealsApiProvider.updateLocation(location);

  void processVendors(Vendors vendors) {
    globals.dealsApiProvider.vendorsQueried
      .difference(HashSet.from(vendors.getVendorList().map((vendor) => vendor.key).toList()))
      .forEach((removedVendor) {
        globals.dealsApiProvider.removeDealsForVendor(removedVendor);
      });
    
    if (!vendors.isLoading && vendors.count == 0){
      globals.dealsApiProvider.noVendorsFound();
    }
    vendors.getVendorList().forEach((vendor) {
      if (!globals.dealsApiProvider.containsDealsFor(vendor)){
        globals.dealsApiProvider.getDealsForVendor(vendor);
      }
    });
  }
  
  void setFavorite(String dealId, bool favorited){
    globals.dealsApiProvider.setFavorite(dealId, favorited);
  }

  Stream<Vendors> getVendorStream() => globals.vendorApiProvider.vendorStream;
  Stream<Deals> getDealsStream() => globals.dealsApiProvider.dealsStream;
}