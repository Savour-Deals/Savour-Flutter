import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/utils.dart' as globals;

class DealsApiProvider {
  HashMap _vendorMap = HashMap<String, Vendor>();
  HashSet favorites = HashSet();
  final DatabaseReference _dealsRef = FirebaseDatabase().reference().child("Deals");
  final DatabaseReference _filtersRef = FirebaseDatabase().reference().child("appData").child("filters");
  final StreamController<Deals> _dealController = StreamController<Deals>();
  Stream<Deals> dealsStream;
  final Deals _deals = Deals();
  String _userId;


  DealsApiProvider() {
    dealsStream = _dealController.stream.asBroadcastStream();
    _filtersRef.onValue.listen((datasnapshot) {
      if (datasnapshot.snapshot.value != null) {
        for (var filter in datasnapshot.snapshot.value){
          _deals.addFilter(filter);
        }
        _dealController.add(_deals);
      }
    });
    this.init();
  }

  Future<void> init() async {
    FirebaseDatabase().reference().child("Users").child(FirebaseAuth.instance.currentUser.uid).child("favorites").onValue.listen((datasnapshot) {
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

  void doneLoading(){
    _deals.doneLoading();
    _dealController.add(_deals);
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
          if(!_deals.isLoading && newDeal.isLive){
            _deals.doneLoading();
          }
        });
        _dealController.add(_deals);
      }
    });
  }

  Future<Deal> getDealByKey(String key) async {
    if (_deals.containsDeal(key)){
      return _deals.getDealByKey(key);
    }
    return await _dealsRef.child(key).once().then((snap) async {
      final vendor = await globals.vendorApiProvider.getVendorByKey(snap.value["vendor_id"]);
      Deal newDeal = new Deal.fromSnapshot(snap, vendor, _userId);
      newDeal.favorited = favorites.contains(newDeal.key);
      _deals.addDeal(newDeal);
      _dealController.add(_deals);
      return newDeal;
    });
  }

  void removeDealsForVendor(Vendor vendor){
    _deals.removeDealWithVendorKey(vendor.key);
    _vendorMap.remove(vendor.key);
  }

  Future<void> setFavorite(String dealId, bool favorited) async {
    if (_deals.getDealByKey(dealId) != null) {
      final favoriteRef = FirebaseDatabase().reference().child("Users").child(_userId).child("favorites").child(dealId);
      if (favorited){
        favoriteRef.set(dealId);
      }else{
        favoriteRef.remove();
      }
      favorites.remove(dealId);
      _deals.setFavoriteByKey(dealId, favorited);
      _dealController.add(_deals);
    } else {
      throw("Deal not found when trying to favorite."); 
    }
  }

  void updateDeal(Deal deal) {
    _deals.addDeal(deal);
  }

  Deals get deals => _deals;
  HashSet get vendorsQueried => HashSet.from(_vendorMap.keys);
}