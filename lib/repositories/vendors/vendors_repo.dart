
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';

import 'vendors_provider.dart';


class VendorRepository {
  final VendorsApiProvider _vendorsApiProvider; 

  VendorRepository(this._vendorsApiProvider);

  void getVendorsForLocation(Position location) => _vendorsApiProvider.queryByLocation(location);

  void updateLocation(Position location) => _vendorsApiProvider.updateLocation(location);

  Stream<Vendors> getVendorStream() => _vendorsApiProvider.vendorStream;

  VendorsApiProvider get vendorsProvider => _vendorsApiProvider;
}