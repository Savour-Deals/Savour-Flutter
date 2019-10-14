

import 'package:firebase_database/firebase_database.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'deal_model.dart';

enum RedemptionType{
  deal,
  loyaltyCheckin,
  loyaltyRedeem
}

class Redemption {
  String key;
  String dealID;
  String vendorID;
  String description;
  String redemptionPhoto;
  int timestamp;
  String type;
  Deal deal;
  Vendor vendor;

  Redemption(this.key,this.dealID,this.vendorID,this.description,this.redemptionPhoto,this.timestamp,this.type);

  Redemption.fromSnapshot(DataSnapshot snapshot) {
    key  = snapshot.key;
    dealID =  snapshot.value["deal_id"]?? "";
    vendorID = snapshot.value["vendor_id"]?? "";
    description = snapshot.value["description"]?? "";
    timestamp = snapshot.value["timestamp"]?? 0;
    type = snapshot.value["type"]?? "";
    redemptionPhoto = (redemptionType == RedemptionType.deal? snapshot.value["deal_photo"]: snapshot.value["vendor_photo"])?? "";
  }

  Redemption.fromMap(String _key, dynamic data) {
    key  = _key;
    dealID =  data["deal_id"]?? "";
    vendorID = data["vendor_id"]?? "";
    description = data["description"]?? "";
    timestamp = data["timestamp"]?? 0;
    type = data["type"]?? "";
    redemptionPhoto = (redemptionType == RedemptionType.deal? data["deal_photo"]: data["vendor_photo"])?? "";
  }

  void setDeal(Deal _deal){
    deal = _deal;
  }

  void setVendor(Vendor _vendor){
    vendor = _vendor;
  }

  RedemptionType get redemptionType {
    switch (type) {
      case "loyalty":
        return RedemptionType.loyaltyRedeem;
      case "loyalty_checkin":
        return RedemptionType.loyaltyCheckin;
      default:
        return RedemptionType.deal;
    }
  } 

  bool isCheckin(){
    return type == "loyalty";
  }
}