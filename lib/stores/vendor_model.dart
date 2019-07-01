import 'package:firebase_database/firebase_database.dart';
import 'package:latlong/latlong.dart';

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
  //  loyalty {
  //       code: string;
  //       count: number;
  //       deal: string;
  //       points: {
  //           mon: number;
  //           tues: number;
  //           wed: number;
  //           thurs: number;
  //           fri: number;
  //           sat: number;
  //           sun : number;
  //       }
  //   }
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
    key = snapshot.key;
    name = snapshot.value["name"];
    address = snapshot.value["address"];
    photo  = snapshot.value["photo"];
    description =  snapshot.value["description"];
    menu = snapshot.value["menu"];
    isPreferred = snapshot.value["preferred"] ?? false;
    var days = snapshot.value["daily_hours"];
    if (days != null){
      dailyHours.add(days["mon"]);
      dailyHours.add(days["tues"]);
      dailyHours.add(days["wed"]);
      dailyHours.add(days["thur"]);
      dailyHours.add(days["fri"]);
      dailyHours.add(days["sat"]);
      dailyHours.add(days["sun"]);
    }
    lat = _lat;
    long = _long;
  }
      
}