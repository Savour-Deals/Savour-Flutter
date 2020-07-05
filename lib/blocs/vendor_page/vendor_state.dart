import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';

abstract class VendorState extends Equatable {
  final Position location; 

  const VendorState(this.location);

  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'VendorState { vendors }';
}

class VendorUninitialized extends VendorState {
  VendorUninitialized(Position location) : super(location);
    @override
  List<Object> get props => [];

  @override
  String toString() =>
      'VendorUninitialized { vendors }';
}

class VendorLoading extends VendorState {
  VendorLoading(Position location) : super(location);
    @override
  List<Object> get props => [];

  @override
  String toString() =>
      'VendorLoading { vendors }';
}

class VendorError extends VendorState {
  VendorError(Position location) : super(location);
  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'VendorErrors { vendors }';
}

class VendorLoaded extends VendorState {
  final Stream<Vendors> vendorStream;
  VendorLoaded(Position location, this.vendorStream) : super(location);

  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'VendorLoaded { vendors }';
}