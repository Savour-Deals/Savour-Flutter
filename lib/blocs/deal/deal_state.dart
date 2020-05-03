import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

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
  const DealLoaded(location) : super(location);

  @override
  List<Object> get props => [location];

  @override
  String toString() =>
      'DealLoaded { deals }';
}