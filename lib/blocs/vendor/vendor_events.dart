import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

abstract class VendorEvent extends Equatable {

  const VendorEvent();
  
  @override
  List<Object> get props => [];
}

class FetchVendors extends VendorEvent {
  final Position location;

  const FetchVendors({@required this.location}) : assert(location != null);
}