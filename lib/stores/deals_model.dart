import 'package:geolocator/geolocator.dart';

import 'deal_model.dart';

class Deals {
  List<Deal> _deals = [];
  // Map<String,List<Deal>> _filteredDeals = {};
  List<String> filters = [];
  Position location;
  bool _isLoading = true;

  Deals();

  addDeal(Deal newDeal){
    var idx = this._deals.indexWhere((d1) => d1.key == newDeal.key);
    if(idx<0){//add newDeal if it doesnt exit
      this._deals.add(newDeal);
      // for(var dealFilter in this.filters){
      //   _filteredDeals[dealFilter].add(newDeal);
      //   _filteredDeals[dealFilter] = sortByDistance(_filteredDeals[dealFilter]);
      // }
    }else{//otherwise, update the deal
      _deals[idx] = newDeal;
    }
  }

  removeDealWithVendorKey(String key){
    this._deals.removeWhere((deal)=> deal.vendor.key == key);
    // for (var filter in filters){
    //   _filteredDeals[filter].removeWhere((deal)=> deal.vendor.key == key);
    // }
  }

  setFavoriteByKey(String key, bool favorite){
    var idx = this._deals.indexWhere((deal)=> deal.key == key);
    this._deals[idx].favorited = favorite;
    // for (var filter in this._deals[idx].filters){
    //   var fidx = _filteredDeals[filter].indexWhere((deal)=> deal.key == key);
    //   if (fidx>0){
    //     _filteredDeals[filter][fidx].favorited = favorite;
    //   }
    // }
  }

  addFilter(String filter){
    this.filters.add(filter);
    // this._filteredDeals[filter] = [];
  }

    List<Deal> getAllDeals(){
      var now = DateTime.now().millisecondsSinceEpoch~/1000;
      var halfhour = 1800*3;
      return this._deals.where((deal) => (!deal.redeemed || (now-deal.redeemedTime~/1000 < halfhour) ) && deal.isLive).toList();
    }

  /////////////////////////////////////////////////////////
  ///                                                   ///
  ///           Getters for all non-gold deals          ///    
  ///                                                   ///
  /////////////////////////////////////////////////////////
  //These getter functions will filter out inactive or redeemed deals so they dont mess up the display of the deal "pages"
  List<Deal> getAllStandardDeals(){
    var now = DateTime.now().millisecondsSinceEpoch~/1000;
    var halfhour = 1800*3;
    return this._deals.where((deal) => !deal.isGold && (!deal.redeemed || (now-deal.redeemedTime~/1000 < halfhour) ) && deal.isLive).toList();
  }

  List<Deal> getAllStandardDealsPlusInactive(){
    return this._deals;
  }

  List<Deal> getStandardDealsByValue(){
    var sortedDeals = getAllStandardDeals();
    sortedDeals.sort((a, b) {
      var comp = b.value.compareTo(a.value);
      if (comp == 0){
        return compareDistance(a, b);
      }
      return comp;
    });
    return sortedDeals;
  }

  List<Deal> getStandardDealsByDistance(){    
    return sortByDistance(getAllStandardDeals());
  }

  List<Deal> getStandardDealsByFilter(int idx){
    var filtDeals = getAllStandardDeals().where((deal) => deal.filters.contains(filters[idx].toLowerCase())).toList();
    return sortByDistance(filtDeals);
  }

    /////////////////////////////////////////////////////////
  ///                                                   ///
  ///           Getters for all gold deals              ///    
  ///                                                   ///
  /////////////////////////////////////////////////////////
  //These getter functions will filter out inactive or redeemed deals so they dont mess up the display of the deal "pages"
  List<Deal> getAllGoldDeals(){
    var now = DateTime.now().millisecondsSinceEpoch~/1000;
    var halfhour = 1800*3;
    return this._deals.where((deal) => deal.isGold && (!deal.redeemed || (now-deal.redeemedTime~/1000 < halfhour) ) && deal.isLive).toList();
  }

  List<Deal> getAllGoldDealsPlusInactive(){
    return this._deals.where((deal) => deal.isGold).toList();
  }

  List<Deal> getGoldDealsByValue(){
    var sortedDeals = getAllGoldDeals();
    sortedDeals.sort((a, b) {
      var comp = b.value.compareTo(a.value);
      if (comp == 0){
        return compareDistance(a, b);
      }
      return comp;
    });
    return sortedDeals;
  }

  List<Deal> getGoldDealsByDistance(){    
    return sortByDistance(getAllGoldDeals());
  }

  List<Deal> getGoldDealsByFilter(int idx){
    var filtDeals = getAllGoldDeals().where((deal) => deal.filters.contains(filters[idx].toLowerCase())).toList();
    return sortByDistance(filtDeals);
  }

  bool containsDeal(String key){
    return _deals.indexWhere((deal) => deal.key == key) >=0 ;
  }

  Deal getDealByKey(String key){
    return _deals.firstWhere((deal) => deal.key == key, orElse: () => null,);
  }

  List<Deal> getFavorites(){
    return sortByDistance(getAllDeals().where((deal) => deal.favorited).toList());
  }

  int compareDistance(Deal a, Deal b){
    return a.vendor.distanceMilesFrom(location.latitude,location.longitude).compareTo(b.vendor.distanceMilesFrom(location.latitude,location.longitude));
  }

  List<Deal> sortByDistance(List<Deal> deals){
    deals.sort((a, b) => compareDistance(a, b));
    return deals;
  }

  void setLocation(Position _location){
    this.location = _location;
  }

  void doneLoading(){
    this._isLoading = false;
  }

  bool get isLoading => _isLoading;

  int get count => _deals.length;
}