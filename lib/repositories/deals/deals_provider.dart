import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

class DealsApiProvider {
  HashMap _vendorMap = HashMap<String, Vendor>();
  HashSet favorites = HashSet();
  final DatabaseReference _dealsRef = FirebaseDatabase().reference().child("Deals");
  final StreamController<Deals> _dealController = StreamController<Deals>();
  Stream<Deals> dealsStream;
  final Deals _deals;
  final String _userId;


  DealsApiProvider(this._deals, this._userId) {
    dealsStream = _dealController.stream.asBroadcastStream();
    FirebaseDatabase().reference().child("appData").child("filters").onValue.listen((datasnapshot) {
      if (datasnapshot.snapshot.value != null) {
        for (var filter in datasnapshot.snapshot.value){
          _deals.addFilter(filter);
        }
        _dealController.add(_deals);
      }
    });
    FirebaseDatabase().reference().child("Users").child(_userId).child("favorites").onValue.listen((datasnapshot) {
      if (datasnapshot.snapshot.value != null) {
        favorites.addAll(Map<String, String>.from(datasnapshot.snapshot.value).keys);
        _deals.getAllDeals().forEach((deal) { 
          _deals.setFavoriteByKey(deal.key, favorites.contains(deal.key));
        });
        _dealController.add(_deals);
      }
    });
  }

  void updateLocation(Position location){
    _deals.setLocation(location);
    _dealController.add(_deals);
  }

  bool containsDealsFor(Vendor vendor){
    return _vendorMap.containsKey(vendor.key);
  }

  void getDealsForVendor(Vendor vendor) {
    _vendorMap[vendor.key] = vendor;
    _dealsRef.orderByChild("vendor_id").equalTo(vendor.key).onValue.listen((dealEvent) {
      if (dealEvent.snapshot.value != null){
        Map<String, dynamic> dealDataMap = new Map<String, dynamic>.from(dealEvent.snapshot.value);
        dealDataMap.forEach((key,data){
          Deal newDeal = new Deal.fromMap(key, data, vendor, _userId);
          newDeal.favorited = favorites.contains(newDeal.key);
          _deals.addDeal(newDeal);
        });
        _dealController.add(_deals);
      }
    });
  }

  void removeDealsForVendor(Vendor vendor){
    _deals.removeDealWithVendorKey(vendor.key);
    _vendorMap.remove(vendor.key);
  }

  HashSet get vendorsQueried => HashSet.from(_vendorMap.keys);
}
class DealCacheItem {
  final Deal deal;
  final DateTime timestamp;

  DealCacheItem(this.deal, this.timestamp);
}