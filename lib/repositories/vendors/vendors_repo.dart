import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

import 'vendors_provider.dart';


class VendorRepository {
  final _vendorsApiProvider = VendorsApiProvider();

//Todo return Vendors object stream...
  Stream<List<VendorCacheItem>> fetchVendorsListByLocation(Position location) => _vendorsApiProvider.vendorStreamByLocation(location);
}