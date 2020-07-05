import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

abstract class DealEvent extends Equatable {
  const DealEvent();
  
  @override
  List<Object> get props => [];
}

class FetchDeals extends DealEvent {
  final Position location;

  const FetchDeals({@required this.location}) : assert(location != null);
}


class UpdateDealsLocation extends DealEvent {
  final Position location;

  const UpdateDealsLocation({@required this.location}) : assert(location != null);
}