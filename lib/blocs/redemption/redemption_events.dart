import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';

abstract class RedemptionEvent extends Equatable {
  const RedemptionEvent();
  
  @override
  List<Object> get props => [];
}

class FetchDeal extends RedemptionEvent {
  final String id;

  const FetchDeal({@required this.id}) : assert(id != null);
}


class RedeemDeal extends RedemptionEvent {
final Deal deal;

  const RedeemDeal({@required this.deal}) : assert(deal != null);
}