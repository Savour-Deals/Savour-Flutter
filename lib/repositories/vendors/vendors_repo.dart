import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';

import 'vendors_provider.dart';


class VendorRepository {
  final _vendorsApiProvider = VendorsApiProvider(); 

  VendorRepository();

  Stream<Vendors> fetchVendorsListByLocation(Position location) => _vendorsApiProvider.vendorStreamByLocation(location);
}