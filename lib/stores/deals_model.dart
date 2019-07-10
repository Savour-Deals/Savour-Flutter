import 'package:geolocator/geolocator.dart';

import 'deal_model.dart';

class Deals {
  List<Deal> _deals = [];
  List<String> filters = [];

  Deals();

  addDeal(Deal newDeal){
    var idx = this._deals.indexWhere((d1) => d1.key == newDeal.key);
    if(idx<0){//add newDeal if it doesnt exit
      this._deals.add(newDeal);
    }else{//otherwise, update the deal
      _deals[idx] = newDeal;
    }
  }

  removeDealWithVendorKey(String key){
    this._deals.removeWhere((deal)=> deal.vendor.key == key);
  }

  setFavoriteByKey(String key, bool favorite){
    this._deals[this._deals.indexWhere((deal)=> deal.key == key)].favorited = favorite;
  }

  addFilter(String filter){
    this.filters.add(filter);
  }

  //These getter functions will filter out inactive or redeemed deals so they dont mess up the display of the deal "pages"
  List<Deal> getAllDeals(){
    var now = DateTime.now().millisecondsSinceEpoch~/1000;
    var halfhour = 1800*3;
    return this._deals.where((deal)=> (!deal.redeemed || (now-deal.redeemedTime~/1000 > halfhour) )&& deal.isLive()).toList();
  }

  List<Deal> getDealsByValue(){
    var sortedDeals = getAllDeals();
    sortedDeals.sort((a, b) => b.value.compareTo(a.value));
    return sortedDeals;
  }

  List<Deal> getDealsByDistance(Position location){
    var sortedDeals = getAllDeals();
    sortedDeals.sort((a, b) => a.vendor.distanceMilesFrom(location.latitude,location.longitude).compareTo(b.vendor.distanceMilesFrom(location.latitude,location.longitude)));
    return sortedDeals;
  }

  List<Deal> getDealsByFilter(int idx){
    return getAllDeals().where((deal) => deal.filters.contains(filters[idx].toLowerCase())).toList();
  }

  bool containsDeal(String key){
    return _deals.indexWhere((deal) => deal.key == key) >=0 ;
  }

  Deal getDealByKey(String key){
    return _deals.firstWhere((deal) => deal.key == key);
  }

  List<Deal> getFavorites(){
    return getAllDeals().where((deal) => deal.favorited).toList();
  }
}