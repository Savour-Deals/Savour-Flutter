import 'package:firebase_database/firebase_database.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

class Deal {
  String key;
  String photo;
  String description;
  Vendor vendor;
  int start;
  int end;
  List<bool> activeDays = [false, false, false, false, false, false, false]; // mon - sun => 0 - 6
  
  Deal(this.key, this.description, this.photo, this.vendor, this.start, this.end);

  // Live is whether or not the deal is between the start and end date
  bool isLive(){
    // TODO: Increase functionality to match native apps
    var now = new DateTime.now().millisecondsSinceEpoch;
    return now > start && now < end;
  }

  // Active is if the deal is redeemable at the current time of the day
  bool isActive(){
    // TODO: Increase functionality to match native apps
    var now = new DateTime.now();
    var startDateTime = new DateTime.fromMillisecondsSinceEpoch(start);
    var endDateTime = new DateTime.fromMillisecondsSinceEpoch(end);
    if (activeDays[now.weekday]){
      //this deal is active for the current day of the week 
      
    }
    return false;
  }

  String infoString(){
    if (isLive()){
      if (isActive()){
        //TODO: check if deal runs all day or till a specific time
        return "This Deal is active until ";//return how long the deal is for 
      }else{
        var now = new DateTime.now();
        if (activeDays[now.weekday]){
          //The deal is not in the time frame of active
          //TODO: Find the start and endtime and retrun a string for it
          return "";
        }
        //the deal is not active on this day
        //TODO: find the days the deal is active and return a string for it
        return "";
      }
    }
    return "This deal is not available.";//This should not be shown to the user
  }

  Deal.fromSnapshot(DataSnapshot snapshot, Vendor _vendor){
    key = snapshot.key;
    vendor = _vendor;
    photo  = snapshot.value["photo"];
    description =  snapshot.value["deal_description"];
    start = snapshot.value["start_time"];
    end = snapshot.value["end_time"];
    var days = snapshot.value["active_days"];
    activeDays.add(days["mon"]);
    activeDays.add(days["tues"]);
    activeDays.add(days["wed"]);
    activeDays.add(days["thur"]);
    activeDays.add(days["fri"]);
    activeDays.add(days["sat"]);
    activeDays.add(days["sun"]);
  }

  Deal.fromMap(String _key, dynamic data, Vendor _vendor){
      key = _key;
      vendor = _vendor;
      photo  = data["photo"];
      description =  data["deal_description"];
      start = data["start_time"];
      end = data["end_time"];
      var days = data["active_days"];
      activeDays.add(days["mon"]);
      activeDays.add(days["tues"]);
      activeDays.add(days["wed"]);
      activeDays.add(days["thur"]);
      activeDays.add(days["fri"]);
      activeDays.add(days["sat"]);
      activeDays.add(days["sun"]);
  }
}