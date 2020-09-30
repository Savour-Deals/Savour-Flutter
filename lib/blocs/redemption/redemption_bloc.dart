
import 'package:bloc/bloc.dart';
import 'package:savour_deals_flutter/repositories/deals/deals_repo.dart';

import 'redemption_events.dart';
import 'redemption_state.dart';

export 'redemption_events.dart';
export 'redemption_state.dart';




class RedemptionBloc extends Bloc<RedemptionEvent, RedemptionState> {
  final DealRepository _dealsRepo = DealRepository();

  RedemptionBloc() : super(RedemptionUninitialized());

  @override
  Stream<RedemptionState> mapEventToState(RedemptionEvent event) async* {
    if (event is FetchDeal) {
      yield RedemptionLoading();
      try {
        final deal = await _dealsRepo.getDealById(event.id);
        yield RedemptionLoaded(deal);
      } catch (error) {
        print(error);
        yield RedemptionError();
      }
    }if (event is RedeemDeal) {
      yield RedemptionLoading();
      try {
        final deal = await _dealsRepo.redeemDeal(event.deal);
        yield RedemptionLoaded(deal);
      } catch (error) {
        print(error);
        yield RedemptionError();
      }
    }
  }
}