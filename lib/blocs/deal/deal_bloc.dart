
import 'package:bloc/bloc.dart';
import 'package:savour_deals_flutter/repositories/deals/deals_repo.dart';

import 'deal_events.dart';
import 'deal_state.dart';

export 'deal_events.dart';
export 'deal_state.dart';




class DealBloc extends Bloc<DealEvent, DealState> {
  final DealRepository _dealsRepo = DealRepository();

  DealBloc();

  @override
  DealState get initialState => DealUninitialized(null);

  @override
  Stream<DealState> mapEventToState(DealEvent event) async* {
    if (event is FetchDeals) {
      yield DealLoading(event.location);
      try {
        final Map<String, dynamic> streams = _dealsRepo.getDealsForLocation(event.location);
        yield DealLoaded(event.location, streams["DEAL"], streams["VENDOR"]);
      } catch (error) {
        print(error);
        yield DealError(event.location);
      }
    }if (event is UpdateDealsLocation) {
      final DealLoaded previousState = (state as DealLoaded);
      yield DealLoading(event.location);
      try {
        _dealsRepo.updateDealsLocation(event.location);
        yield DealLoaded(event.location, previousState.dealStream, previousState.vendorStream);
      } catch (error) {
        print(error);
        yield DealError(event.location);
      }
    }
  }
}