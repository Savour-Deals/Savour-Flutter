
import 'package:bloc/bloc.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_repo.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';

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
        final Stream<Vendors> vendors = _vendorsRepo.fetchVendorsListByLocation(event.location);
        yield VendorLoaded(vendorStream: vendors);
      } catch (error) {
        print(error);
        yield VendorError();
      }
    }
  }
}