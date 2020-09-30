
import 'package:bloc/bloc.dart';
import 'package:savour_deals_flutter/blocs/wallet/wallet_events.dart';
import 'package:savour_deals_flutter/repositories/deals/deals_repo.dart';
import 'package:savour_deals_flutter/repositories/redemptions/redemptions_repo.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_repo.dart';

import 'wallet_events.dart';
import 'wallet_state.dart';

export 'wallet_events.dart';
export 'wallet_state.dart';




class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final DealRepository _dealsRepo = DealRepository();
  final VendorRepository _vendorRepo = VendorRepository();
  final RedemptionRepository _redemptionRepo = RedemptionRepository();

  WalletBloc() : super(WalletUninitialized(null));

  @override
  Stream<WalletState> mapEventToState(WalletEvent event) async* {
    if (event is FetchData) {
      yield WalletLoading(event.location);
      try {
        _redemptionRepo.getRedemptions();
        yield WalletLoaded(event.location);
      } catch (error) {
        print(error);
        yield WalletError(event.location);
      }
    }
    if (event is UpdateWalletLocation) {
      yield WalletLoading(event.location);
      try {
        _dealsRepo.updateDealsLocation(event.location);
        _vendorRepo.updateLocation(event.location);
        _redemptionRepo.getRedemptions();
        yield WalletLoaded(event.location);
      } catch (error) {
        print(error);
        yield WalletError(event.location);
      }
    }
  }
}