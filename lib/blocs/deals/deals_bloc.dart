
import 'package:bloc/bloc.dart';
import 'package:savour_deals_flutter/repositories/deals/deals_repo.dart';

import 'deals_events.dart';
import 'deals_state.dart';

export 'deals_events.dart';
export 'deals_state.dart';




class DealsBloc extends Bloc<DealsEvent, DealsState> {
  final DealRepository _dealsRepo = DealRepository();

  DealsBloc() : super(DealsUninitialized(null));

  @override
  Stream<DealsState> mapEventToState(DealsEvent event) async* {
    if (event is FetchDeals) {
      yield DealsLoading(event.location);
      try {
        _dealsRepo.queryDealsForLocation(event.location);
        final Map<String, dynamic> streams = _dealsRepo.getDeals();
        yield DealsLoaded(event.location, streams["DEAL"], streams["VENDOR"]);
      } catch (error) {
        print(error.toString());
        yield DealsError(event.location);
      }
    }if (event is UpdateDealsLocation) {
      final DealsLoaded previousState = (state as DealsLoaded);
      yield DealsLoading(event.location);
      try {
        _dealsRepo.updateDealsLocation(event.location);
        yield DealsLoaded(event.location, previousState.dealStream, previousState.vendorStream);
      } catch (error) {
        print(error);
        yield DealsError(event.location);
      }
    }
  }
}