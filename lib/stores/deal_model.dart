import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:savour_deals_flutter/utils.dart';

class Deal {
  String key;
  String photo;
  String description;
  Vendor vendor;
  int start;
  int end;
  bool favorited = false;
  bool redeemed;
  int redeemedTime;
  String type;
  String code;
  List<bool> activeDays = []; // mon - sun => 0 - 6
  
  Deal(this.key, this.description, this.photo, this.vendor, this.start, this.end, this.favorited, this.activeDays, this.code, this.redeemed, this.redeemedTime, this.type);

  // Live is whether or not the deal is between the start and end date
  bool isLive(){
    // TODO: unset as favorite
    var now = new DateTime.now();
    var startOfToday = new DateTime(now.year, now.month, now.day);
    //begin showing deal at midnight, the day of and end showing it when it expires
    return startOfToday.millisecondsSinceEpoch >= start && now.millisecondsSinceEpoch <= end;
  }

  // Active is if the deal is redeemable at the current time of the day
  bool isActive(){
    final now = DateTime.now();
    final startDateTime = DateTime.fromMillisecondsSinceEpoch(start);
    final endDateTime = DateTime.fromMillisecondsSinceEpoch(end);
    var nowHour = now.hour;
    DateTime startOfToday;
    if (nowHour < 5){//To solve problem with checking for deals after midnight... might have better way
      startOfToday = new DateTime(now.year, now.month, now.day).subtract(new Duration(days: 1));
    }else{
      startOfToday = new DateTime(now.year, now.month, now.day);
    }
    final startTime = startOfToday.add(new Duration(hours: startDateTime.hour, minutes: startDateTime.minute));
    var endTime = startOfToday.add(new Duration(hours: endDateTime.hour, minutes: endDateTime.minute));
    if (startTime.compareTo(endTime) > 0) {//endTime is after startTime
      //Deal goes past midnight (might be typical of bar's drink deals)
      endTime = endTime.add(new Duration(days: 1));
    }
    if (activeDays[startTime.weekday-1]){//Active today
      if (now.compareTo(startTime) >= 0 && now.compareTo(endTime) <= 0){
        return true;
      }else if (startTime.compareTo(endTime) == 0){
          return true;//"active all day!"
      }else{
        return false;
      }
    }else{//Not Active today
      return false;
    }
  }

  String infoString(){
    final now = DateTime.now();
    final startDateTime = DateTime.fromMillisecondsSinceEpoch(start);
    final endDateTime = DateTime.fromMillisecondsSinceEpoch(end);
    var nowHour = now.hour;
    DateTime startOfToday;
    if (nowHour < 5){//To solve problem with checking for deals after midnight... might have better way
        startOfToday = new DateTime(now.year, now.month, now.day).subtract(new Duration(days: 1));
    }else{
        startOfToday = new DateTime(now.year, now.month, now.day);
    }
    final startTime = startOfToday.add(new Duration(hours: startDateTime.hour, minutes: startDateTime.minute));
    var endTime = startOfToday.add(new Duration(hours: endDateTime.hour, minutes: endDateTime.minute));
    if (startTime.compareTo(endTime) > 0) {//endTime is after startTime
        //Deal goes past midnight (might be typical of bar's drink deals)
        endTime = endTime.add(new Duration(days: 1));
    }
    if (activeDays[startTime.weekday-1]){//Active today
      var formatter = new DateFormat('h:mm a');
      if (now.compareTo(startTime) > 0 && now.compareTo(endTime) < 0){
          return "Valid until " + formatter.format(endTime);
      }else if (startTime.compareTo(endTime) == 0){
          return  "";//"active all day!"
      }else{
          return "available from " + formatter.format(startTime) + " to " + formatter.format(endTime);
      }
    }else{//Not Active today
        var inactiveString = "";
        for (var i = 0; i < 7; i++) {
          if (activeDays[i]){
              if (inactiveString != ""){
                  inactiveString = inactiveString + " ";
              }
              inactiveString = inactiveString + ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday",][i];
          }
        }
        inactiveString = "available " + inactiveString.replaceAll(" ", ", ");
        return inactiveString;
    }
  }

  String countdownString(){
    final now = DateTime.now();
    final startOfToday = new DateTime(now.year, now.month, now.day);
    final startDateTime = DateTime.fromMillisecondsSinceEpoch(start);
    final endDateTime = DateTime.fromMillisecondsSinceEpoch(end);
    final startOfEndDay = new DateTime(endDateTime.year, endDateTime.month, endDateTime.day);
    var daysLeft = startOfEndDay.difference(startOfToday).inDays; //approximate days left by the start of today to start of the last day live
    if ((startDateTime.hour == endDateTime.hour && startDateTime.minute == endDateTime.minute) || (now.millisecondsSinceEpoch <= end && now.millisecondsSinceEpoch >= start)){
      if (daysLeft > 7){
        return "";//return empty string if more than a week left
      }else if (daysLeft > 1){
        return daysLeft.toString() + " days left";
      }else if (daysLeft == 1){
        return "Deal expires tomorrow!";
      }
    }
    return "Deal expires today!";
  }

  
  Deal.fromSnapshot(DataSnapshot snapshot, Vendor _vendor, String uid) {
    redeemed = false;
    redeemedTime = 0;
    if (snapshot.value["redeemed"] != null){
      var val = snapshot.value["redeemed"];
      if (val[uid] != null){//if there is a redemption time
        var now = DateTime.now().millisecondsSinceEpoch;
        var rTime = snapshot.value["redeemed"][uid].toInt()*1000;//database may contain doubles from old code so round 
        if (now-rTime > 60*60*24*7*2*1000) {
            //If redeemed 2 weeks ago, allow user to use deal again - Should be changed in the future
            final randStr = Utils.createCryptoRandomString(10);//create a random string to use for changing redemption id
            final ref = FirebaseDatabase().reference().child("Deals").child(key).child("redeemed");
            ref.child(uid).remove();
            ref.child(uid+randStr).set(rTime/1000);
        }else{
            redeemed = true;
            redeemedTime = rTime;
        }
      }
    }
    key = snapshot.key;
    vendor = _vendor;
    photo  = snapshot.value["photo"];
    description =  snapshot.value["deal_description"];
    start = snapshot.value["start_time"]*1000;
    end = snapshot.value["end_time"]*1000;
    code = snapshot.value["code"] ?? "";
    type = snapshot.value["filter"] ?? "";

    var days = snapshot.value["active_days"];
    activeDays.add(days["mon"]);
    activeDays.add(days["tues"]);
    activeDays.add(days["wed"]);
    activeDays.add(days["thur"]);
    activeDays.add(days["fri"]);
    activeDays.add(days["sat"]);
    activeDays.add(days["sun"]);
  }

  Deal.fromMap(String _key, dynamic data, Vendor _vendor, String uid){
    redeemed = false;
    redeemedTime = 0;
    if (data["redeemed"] != null){
      if (data["redeemed"][uid] != null){//if there is a redemption time
        var now = DateTime.now().millisecondsSinceEpoch;
        var rTime = data["redeemed"][uid].toInt()*1000;//database may contain doubles from old code so round 
        if (now-rTime > 60*60*24*7*2*1000) {
            //If redeemed 2 weeks ago, allow user to use deal again - Should be changed in the future
            final randStr = Utils.createCryptoRandomString(10);//create a random string to use for changing redemption id
            final ref = FirebaseDatabase().reference().child("Deals").child(key).child("redeemed");
            ref.child(uid).remove();
            ref.child(uid+randStr).set(rTime/1000);
        }else{
            redeemed = true;
            redeemedTime = rTime;
        }
      }
    }
    key = _key;
    vendor = _vendor;
    photo  = data["photo"];
    description =  data["deal_description"];
    start = data["start_time"]*1000;
    end = data["end_time"]*1000;
    code = data["code"]; 
    type = data["filter"];

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