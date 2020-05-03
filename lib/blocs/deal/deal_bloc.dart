
import 'package:bloc/bloc.dart';
import 'package:savour_deals_flutter/repositories/deals/deals_repo.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_repo.dart';

import 'deal_events.dart';
import 'deal_state.dart';

export 'deal_events.dart';
export 'deal_state.dart';




class DealBloc extends Bloc<DealEvent, DealState> {
  final DealRepository _dealsRepo;
  final VendorRepository _vendorsRepo;

  DealBloc(this._dealsRepo, this._vendorsRepo);

  @override
  DealState get initialState => DealUninitialized(null);

  @override
  Stream<DealState> mapEventToState(DealEvent event) async* {
    if (event is FetchDeals) {
          print(event.location);

      yield DealLoading(event.location);
      try {
        _dealsRepo.getDealsForLocation(event.location);
        yield DealLoaded(event.location);
      } catch (error) {
        print(error);
        yield DealError(event.location);
      }
    }if (event is UpdateDealsLocation) {
      yield DealLoading(event.location);
      try {
            print(event.location);

        _dealsRepo.updateDealsLocation(event.location);
        yield DealLoaded(event.location);
      } catch (error) {
        print(error);
        yield DealError(event.location);
      }
    }
  }

  DealRepository get dealsRepo => _dealsRepo;
  VendorRepository get vendorsRepo => _vendorsRepo;
}