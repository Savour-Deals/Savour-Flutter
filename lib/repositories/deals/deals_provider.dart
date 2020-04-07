import 'dart:async';

import 'package:savour_deals_flutter/stores/deals_model.dart';

class DealsApiProvider {
  // Future<Deals> fetchDealsList() async {
  //   FirebaseDatabase().reference().child("appData").child("filters").onValue.listen((datasnapshot) {
  //     if (datasnapshot.snapshot.value != null) {
  //       for (var filter in datasnapshot.snapshot.value){
  //         deals.addFilter(filter);
  //       }
  //     }
  //   });

  //   FirebaseDatabase().reference().child("Users").child(user.uid).child("favorites").onValue.listen((datasnapshot) {
  //     if (datasnapshot.snapshot.value != null) {
  //       favorites = new Map<String, String>.from(datasnapshot.snapshot.value);
  //       for (var deal in deals.getAllDeals()){
  //         deals.setFavoriteByKey(deal.key, favorites.containsKey(deal.key));
  //       }
  //     }
  //   });
  //   return Deals.fromLocation();
  // }
}