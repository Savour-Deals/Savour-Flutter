import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';

abstract class DealState extends Equatable {
  final Position location; 

  const DealState(this.location);

  @override
  List<Object> get props => [location];
}

class DealUninitialized extends DealState {
  DealUninitialized(Position location) : super(location);
  @override
  String toString() =>
      'DealUninitialized { deals }';
}

class DealLoading extends DealState {
  DealLoading(Position location) : super(location);

  @override
  String toString() =>
      'DealLoading { deals }';
}

class DealError extends DealState {

  DealError(Position location) : super(location);

  @override
  List<Object> get props => [location];


  @override
  String toString() =>
      'DealError { deals }';
}

class DealLoaded extends DealState {
  final Stream<Deals> dealStream;
  final Stream<Vendors> vendorStream;
  const DealLoaded(location, this.dealStream, this.vendorStream) : super(location);

  @override
  List<Object> get props => [location];

  @override
  String toString() =>
      'DealLoaded { deals }';
}