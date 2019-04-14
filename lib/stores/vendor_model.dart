import 'package:firebase_database/firebase_database.dart';
import 'package:latlong/latlong.dart';

class Vendor {
  final String key;
  final String name;
  final String address;
  final double lat;
  final double long;
  final String photo;
  final String description;
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
  //   daily_hours: {
  //       mon: string;
  //       tues: string;
  //       wed: string;
  //       thurs: string;
  //       fri: string;
  //       sat: string;
  //       sun : string;
  //   }
  
  Vendor(this.key, this.name, this.address, this.description, this.photo, this.lat, this.long);

  double distanceMilesFrom(double fromLat, double fromLong){
    return Distance(roundResult: false).as(LengthUnit.Mile, new LatLng(lat,long),new LatLng(fromLat,fromLong)).toDouble();
  }

  Vendor.fromSnapshot(DataSnapshot snapshot, double _lat, double _long)
      : key = snapshot.key,
        name = snapshot.value["name"],
        address = snapshot.value["address"],
        photo  = snapshot.value["photo"],
        description =  snapshot.value["description"],
        lat = _lat,
        long = _long;
}