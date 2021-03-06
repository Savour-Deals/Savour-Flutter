import 'package:firebase_database/firebase_database.dart';
import 'package:latlong/latlong.dart';

class Loyalty {
  String code;
  int count;
  String deal;
  List<int> points = []; // mon - sun => 0 - 6

  Loyalty(){
    code = "";
    count = -1;
    deal = "";
  }

  int todaysPoints(){
    final now = DateTime.now();
    return points[now.weekday-1];
  }
}

class Vendor {
  String key;
  String name;
  String address;
  double lat;
  double long;
  String photo;
  String description;
  String menu;
  bool isPreferred;
  Loyalty loyalty = Loyalty();
  List<String> dailyHours = []; // mon - sun => 0 - 6
  
  Vendor(this.key, this.name, this.address, this.description, this.photo, this.lat, this.long, this.isPreferred);

  String todaysHours(){
    final now = DateTime.now();
    return dailyHours[now.weekday-1];
  }

  double distanceMilesFrom(double fromLat, double fromLong){
    return Distance(roundResult: false).as(LengthUnit.Mile, new LatLng(lat,long),new LatLng(fromLat,fromLong)).toDouble();
  }

  Vendor.fromSnapshot(DataSnapshot snapshot, double _lat, double _long){
    // print(snapshot.value);
    key = snapshot.key;
    name = snapshot.value["name"]?? "";
    address = snapshot.value["address"]?? "";
    photo  = snapshot.value["photo"]?? "";
    description =  snapshot.value["description"]?? "";
    menu = snapshot.value["menu"]?? "";
    isPreferred = snapshot.value["preferred"] ?? false;
    var loyaltyData = snapshot.value["loyalty"] ?? {};
    if (loyaltyData["loyalty_code"] != null){
      loyalty.code = loyaltyData["loyalty_code"] ?? "";
      loyalty.count = loyaltyData["loyalty_count"] ?? -1;
      loyalty.deal = loyaltyData["loyalty_deal"] ?? "";
      var points = loyaltyData["loyalty_points"];
      if(points != null){
        loyalty.points.add(points["mon"]);
        loyalty.points.add(points["tues"]);
        loyalty.points.add(points["wed"]);
        loyalty.points.add(points["thurs"]);
        loyalty.points.add(points["fri"]);
        loyalty.points.add(points["sat"]);
        loyalty.points.add(points["sun"]);
      }
    }
    var days = snapshot.value["daily_hours"]?? null;
    if (days != null){
      dailyHours.add(days["mon"]);
      dailyHours.add(days["tues"]);
      dailyHours.add(days["wed"]);
      dailyHours.add(days["thurs"]);
      dailyHours.add(days["fri"]);
      dailyHours.add(days["sat"]);
      dailyHours.add(days["sun"]);
    }
    lat = _lat;
    long = _long;
  }

  Vendor.fromMap(String _key, dynamic data, double _lat, double _long){
    key = _key;
    name = data["name"];
    address = data["address"];
    photo  = data["photo"];
    description =  data["description"];
    menu = data["menu"];
    isPreferred = data["preferred"] ?? false;
    var loyaltyData = data.value["loyalty"] ?? {};
    if (loyaltyData != null){
      loyalty.code = loyaltyData["loyalty_code"] ?? "";
      loyalty.count = loyaltyData["loyalty_count"] ?? -1;
      loyalty.deal = loyaltyData["loyalty_deal"] ?? "";
      var points = loyaltyData["loyalty_points"];
      if(points != null){
        loyalty.points.add(points["mon"]);
        loyalty.points.add(points["tues"]);
        loyalty.points.add(points["wed"]);
        loyalty.points.add(points["thurs"]);
        loyalty.points.add(points["fri"]);
        loyalty.points.add(points["sat"]);
        loyalty.points.add(points["sun"]);
      }
    }
    var days = data["daily_hours"]?? null;
    if (days != null){
      dailyHours.add(days["mon"]);
      dailyHours.add(days["tues"]);
      dailyHours.add(days["wed"]);
      dailyHours.add(days["thurs"]);
      dailyHours.add(days["fri"]);
      dailyHours.add(days["sat"]);
      dailyHours.add(days["sun"]);
    }
    lat = _lat;
    long = _long;
  }   
}