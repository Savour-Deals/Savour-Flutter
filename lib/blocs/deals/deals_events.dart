import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

abstract class DealsEvent extends Equatable {
  const DealsEvent();
  
  @override
  List<Object> get props => [];
}

class FetchDeals extends DealsEvent {
  final Position location;

  const FetchDeals({@required this.location}) : assert(location != null);
}


class UpdateDealsLocation extends DealsEvent {
  final Position location;

  const UpdateDealsLocation({@required this.location}) : assert(location != null);
}