
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_provider.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';

import 'package:savour_deals_flutter/utils.dart' as globals;

class VendorRepository {

  VendorRepository();

  Stream<Vendors> getVendorsForLocation(Position location) {
    globals.vendorApiProvider.queryByLocation(location);
    return globals.vendorApiProvider.vendorStream;
  }

  void updateLocation(Position location) => globals.vendorApiProvider.updateLocation(location);

  Stream<Vendors> getVendorStream() => globals.vendorApiProvider.vendorStream;

  VendorsApiProvider get vendorsProvider => globals.vendorApiProvider;
}