
import 'package:bloc/bloc.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_provider.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_repo.dart';

import 'vendor_events.dart';
import 'vendor_state.dart';

export 'vendor_events.dart';
export 'vendor_state.dart';




class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final VendorRepository _vendorsRepo = VendorRepository();

  VendorBloc();

  @override
  VendorState get initialState => VendorUninitialized();

  @override
  Stream<VendorState> mapEventToState(VendorEvent event) async* {
    if (event is FetchVendors) {
      yield VendorLoading();
      try {
        final Stream<List<VendorCacheItem>> vendors = _vendorsRepo.fetchVendorsListByLocation(event.location);
        yield VendorLoaded(vendorStream: vendors);
      } catch (_) {
        yield VendorError();
      }
    }
  }
}