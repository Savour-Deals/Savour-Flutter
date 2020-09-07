import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';

abstract class DealsState extends Equatable {
  final Position location; 

  const DealsState(this.location);

  @override
  List<Object> get props => [location];
}

class DealsUninitialized extends DealsState {
  DealsUninitialized(Position location) : super(location);
  @override
  String toString() =>
      'DealsUninitialized { deals }';
}

class DealsLoading extends DealsState {
  DealsLoading(Position location) : super(location);

  @override
  String toString() =>
      'DealsLoading { deals }';
}

class DealsError extends DealsState {
  DealsError(Position location) : super(location);

  @override
  List<Object> get props => [location];


  @override
  String toString() =>
      'DealsError { deals }';
}

class DealsLoaded extends DealsState {
  final Stream<Deals> dealStream;
  final Stream<Vendors> vendorStream;
  const DealsLoaded(location, this.dealStream, this.vendorStream) : super(location);

  @override
  List<Object> get props => [location];

  @override
  String toString() =>
      'DealsLoaded { deals }';
}