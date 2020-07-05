import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:savour_deals_flutter/utils.dart' as globals;
import 'package:savour_deals_flutter/stores/redemption_model.dart';

class RedemptionsApiProvider {
  final DatabaseReference _redemptionRef = FirebaseDatabase().reference().child("Redemptions");
  final StreamController<List<Redemption>> _redemptionsController = StreamController<List<Redemption>>();
  Stream<List<Redemption>> redemptionsStream;
  List<Redemption> _redemptions;
  bool _loaded = false;

  RedemptionsApiProvider(){
    this._redemptions = [];
    this._redemptionsController.add(this._redemptions);
  }

  Future<Stream<List<Redemption>>> getRedemptions() async {
    final user = await FirebaseAuth.instance.currentUser();
    _redemptionRef.orderByChild("user_id").equalTo(user.uid).onValue.listen((datasnapshot) {
      if (datasnapshot.snapshot.value != null) {
        Map<String, dynamic> redemptionData = new Map<String, dynamic>.from(datasnapshot.snapshot.value);
        redemptionData.forEach((key,data) async {
          var newRedemption = Redemption.fromMap(key, data);
          if (newRedemption.type == "deal"){
            var rdeal = await globals.dealsApiProvider.getDealByKey(newRedemption.dealID);
            if (rdeal != null){
              newRedemption.setDeal(rdeal);
            }
          }else{
            var rvendor = await globals.vendorApiProvider.getVendorByKey(newRedemption.vendorID);
            newRedemption.setVendor(rvendor);
          }
          _redemptions.add(newRedemption);
          _redemptions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _redemptionsController.add(_redemptions);
        });
      }
      _loaded = true;
    });
    return redemptionsStream;
  }

  bool get isLoaded => _loaded;
  List<Redemption> get redemptions => _redemptions;
}