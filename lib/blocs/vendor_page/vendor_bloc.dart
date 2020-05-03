
import 'package:bloc/bloc.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_repo.dart';

import 'vendor_events.dart';
import 'vendor_state.dart';

export 'vendor_events.dart';
export 'vendor_state.dart';




class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final VendorRepository _vendorsRepo;

  VendorBloc(this._vendorsRepo);

  @override
  VendorState get initialState => VendorUninitialized(null);

  @override
  Stream<VendorState> mapEventToState(VendorEvent event) async* {
    if (event is FetchVendors) {
      yield VendorLoading(event.location);
      try {
        _vendorsRepo.getVendorsForLocation(event.location);
        yield VendorLoaded(event.location);
      } catch (error) {
        print(error);
        yield VendorError(event.location);
      }
    }
    if (event is UpdateVendorsLocation) {
      yield VendorLoading(event.location);
      try {
        _vendorsRepo.updateLocation(event.location);
        yield VendorLoaded(event.location);
      } catch (error) {
        print(error);
        yield VendorError(event.location);
      }
    }
  }

  VendorRepository get vendorRepo => _vendorsRepo;
}