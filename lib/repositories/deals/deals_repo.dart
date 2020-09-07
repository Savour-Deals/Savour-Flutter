import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/vendors_model.dart';
import 'package:savour_deals_flutter/utils.dart' as globals;

class DealRepository {

  DealRepository();

  Map<String, dynamic> queryDealsForLocation(Position location) {
    globals.dealsApiProvider.updateLocation(location);
    globals.vendorApiProvider.vendorStream.listen((vendors) => processVendors(vendors));

    globals.vendorApiProvider.queryByLocation(location);
    if (globals.dealsApiProvider.deals.count > 0){
      globals.dealsApiProvider.doneLoading();//if deals have already been loaded, done flag should be set
    }
    return {
      "DEAL" : globals.dealsApiProvider.dealsStream,
      "VENDOR" : globals.vendorApiProvider.vendorStream
    };
  }

  Map<String, dynamic> getDeals() {
    return {
      "DEAL" : globals.dealsApiProvider.dealsStream,
      "VENDOR" : globals.vendorApiProvider.vendorStream
    };
  }

  Map<String, dynamic> getPremiumDeals() {
    return {
      "DEAL" : globals.dealsApiProvider.dealsStream,
      "VENDOR" : globals.vendorApiProvider.vendorStream
    };
  }

  Future<Deal> getDealById(String id) async {
    return await globals.dealsApiProvider.getDealByKey(id);
  }

  void updateDealsLocation(Position location) => globals.dealsApiProvider.updateLocation(location);

  void processVendors(Vendors vendors) {
    globals.dealsApiProvider.vendorsQueried
      .difference(HashSet.from(vendors.getVendorList().map((vendor) => vendor.key).toList()))
      .forEach((removedVendor) {
        globals.dealsApiProvider.removeDealsForVendor(removedVendor);
      });
    
    if (!vendors.isLoading && vendors.count == 0){
      globals.dealsApiProvider.doneLoading();
    }
    vendors.getVendorList().forEach((vendor) {
      if (!globals.dealsApiProvider.containsDealsFor(vendor)){
        globals.dealsApiProvider.getDealsForVendor(vendor);
      }
    });
  }
  
  void setFavorite(String key, bool favorited){
    globals.dealsApiProvider.setFavorite(key, favorited);
  }

  Future<Deal> redeemDeal(Deal deal) async {
    final user = FirebaseAuth.instance.currentUser;
    final redemptionRef = FirebaseDatabase().reference().child("Deals").child(deal.key).child("redeemed").child(user.uid);
    final userRef = FirebaseDatabase().reference().child("Users").child(user.uid);
    final vendorRef = FirebaseDatabase().reference().child("Vendors").child(deal.vendor.key);
    final redemptionTime = deal.redeemedTime = DateTime.now().millisecondsSinceEpoch~/1000;
    redemptionRef.set(redemptionTime);

    //notification subscriptions
    userRef.child("following").child(deal.vendor.key).set(true);
    // OneSignal.shared.sendTag(widget.deal.vendor.key, true);
    OneSignal.shared.getPermissionSubscriptionState().then((status){
      if (status.subscriptionStatus.subscribed){
        vendorRef.child("followers").child(user.uid).set(status.subscriptionStatus.userId);
      }else{
        // if userID is not available (IE the have notifications set off, still log the user as subscribed in firebase)
        vendorRef.child("followers").child(user.uid).set(user.uid);
      }
    });

    deal.redeemed = true;
    deal.redeemedTime = redemptionTime*1000;
    globals.dealsApiProvider.updateDeal(deal);
    return deal;
  }

  // Stream<Vendors> getVendorStream() => globals.vendorApiProvider.vendorStream;
  // Stream<Deals> getDealsStream() => globals.dealsApiProvider.dealsStream;
}