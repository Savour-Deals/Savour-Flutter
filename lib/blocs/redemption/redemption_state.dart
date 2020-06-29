import 'package:equatable/equatable.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';

abstract class RedemptionState extends Equatable {

  const RedemptionState();

  @override
  List<Object> get props => [];
}

class RedemptionUninitialized extends RedemptionState {
  RedemptionUninitialized();
  @override
  String toString() =>
      'RedemptionUninitialized';
}

class RedemptionLoading extends RedemptionState {
  RedemptionLoading();

  @override
  String toString() =>
      'RedemptionLoading';
}

class RedemptionError extends RedemptionState {

  RedemptionError();

  @override
  List<Object> get props => [];


  @override
  String toString() =>
      'RedemptionError';
}

class RedemptionLoaded extends RedemptionState {
  final Deal deal;
  const RedemptionLoaded(this.deal): assert(deal != null);

  @override
  List<Object> get props => [];

  @override
  String toString() =>
      'RedemptionLoaded { deal: ${deal.key} }';
}