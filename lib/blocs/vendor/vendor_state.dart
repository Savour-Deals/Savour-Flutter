import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_provider.dart';

abstract class VendorState extends Equatable {
  const VendorState();

  @override
  List<Object> get props => [];
}

class VendorUninitialized extends VendorState {}

class VendorLoading extends VendorState {}

class VendorError extends VendorState {}

class VendorLoaded extends VendorState {
  final Stream<List<VendorCacheItem>> vendorStream;

  const VendorLoaded({@required this.vendorStream}) : assert(vendorStream != null);

  @override
  List<Object> get props => [vendorStream];

  @override
  String toString() =>
      'VendorLoaded { vendors }';
}