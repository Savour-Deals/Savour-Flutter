
import 'package:bloc/bloc.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_repo.dart';

import 'vendor_events.dart';
import 'vendor_state.dart';

export 'vendor_events.dart';
export 'vendor_state.dart';




class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final VendorRepository _vendorsRepo = VendorRepository();

  VendorBloc();

  @override
  VendorState get initialState => VendorUninitialized(null);

  @override
  Stream<VendorState> mapEventToState(VendorEvent event) async* {
    if (event is FetchVendors) {
      yield VendorLoading(event.location);
      try {
        final vendorStream = _vendorsRepo.getVendorsForLocation(event.location);
        yield VendorLoaded(event.location, vendorStream);
      } catch (error) {
        print(error);
        yield VendorError(event.location);
      }
    }
    if (event is UpdateVendorsLocation) {
      final previousState = (state as VendorLoaded);
      yield VendorLoading(event.location);
      try {
        _vendorsRepo.updateLocation(event.location);
        yield VendorLoaded(event.location, previousState.vendorStream);
      } catch (error) {
        print(error);
        yield VendorError(event.location);
      }
    }
  }
}