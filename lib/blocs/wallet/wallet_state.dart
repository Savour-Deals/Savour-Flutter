import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class WalletState extends Equatable {
  final Position location; 

  const WalletState(this.location);

  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'WalletState {  }';
}

class WalletUninitialized extends WalletState {
  WalletUninitialized(Position location) : super(location);
  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'WalletUninitialized {  }';
}

class WalletLoading extends WalletState {
  WalletLoading(Position location) : super(location);
    @override
  List<Object> get props => [];

  @override
  String toString() =>
      'WalletLoading {  }';
}

class WalletError extends WalletState {
  WalletError(Position location) : super(location);
  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'WalletErrors {  }';
}

class WalletLoaded extends WalletState {
  WalletLoaded(Position location) : super(location);

  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'WalletLoaded {  }';
}