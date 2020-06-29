import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

abstract class WalletEvent extends Equatable {

  const WalletEvent();
  
  @override
  List<Object> get props => [];
}

class FetchData extends WalletEvent {
  final Position location;

  const FetchData({@required this.location}) : assert(location != null);
}

class UpdateWalletLocation extends WalletEvent {
  final Position location;

  const UpdateWalletLocation({@required this.location}) : assert(location != null);
}