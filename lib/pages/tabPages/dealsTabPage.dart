part of tab_lib;

class DealsPageWidget extends StatefulWidget {
  final String text;

  DealsPageWidget(this.text);

  @override
  _DealsPageState createState() => _DealsPageState();
}



class _DealsPageState extends State<DealsPageWidget> {
  DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  DatabaseReference dealRef = FirebaseDatabase().reference().child("Deals");

  final geolocator = Geolocator();
  final geo = Geofire();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10); 
  Position currentLocation;
  Permission permission;
  bool first = true;

  List<Vendor> vendors = [];
  List<Deal> deals = [];

  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    //Intializing geoFire
    geo.initialize("Vendors_Location");
    final _ = await SimplePermissions.requestPermission(Permission.AlwaysLocation);
    GeolocationStatus geolocationStatus = await geolocator.checkGeolocationPermissionStatus();




    if (geolocationStatus == GeolocationStatus.granted) {
      //get inital location and set up for geoquery
      currentLocation = await geolocator.getCurrentPosition();
      geo.queryAtLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
      geo.onKeyEntered.listen((data){
        keyEntered(data);
      });
      geo.onKeyExited.listen((data){
        keyExited(data);
      });
      //Stream location and update query
      geolocator.getPositionStream(locationOptions).listen((Position position) async {
        setState(() {
          currentLocation = position;
        });
        geo.updateLocation(position.latitude, position.longitude, 80.0);
      });
    }
  }

  void keyEntered(dynamic data){
    // print("key entered dealsPage: " + data["key"]);
    var lat = data["lat"];
    var long = data["long"];
    if (this.mounted){
      vendorRef.child(data["key"]).onValue.listen((vendorEvent) => {
        setState(() {
          Vendor newVendor = Vendor.fromSnapshot(vendorEvent.snapshot, lat, long);
          if (!vendors.contains(newVendor)){
            vendors.add(newVendor);
            dealRef.orderByChild("vendor_id").equalTo(newVendor.key).onValue.listen((dealEvent) => {
              setState(() {
                Map<String, dynamic> dealDataMap = new Map<String, dynamic>.from(dealEvent.snapshot.value);
                dealDataMap.forEach((key,data){
                  var thisVendor = vendors.firstWhere((v)=> v.key == data["vendor_id"]);
                  Deal newDeal = new Deal.fromMap(key, data, thisVendor);
                  if(!deals.contains(newDeal)){
                    deals.add(newDeal);
                    deals.sort((d1,d2) => d1.vendor.distanceMilesFrom(lat, long).compareTo(d2.vendor.distanceMilesFrom(lat, long)));
                  }
                });
              })
            });
          }
        })
      });
    }
  }

  void keyExited(dynamic data){
    // print("key exited dealsPage: " + data["key"]);
    if (this.mounted){
      setState(() {
        deals.removeWhere((deal) => deal.vendor.key == data["key"]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (deals.length > 0){
      return ListView.builder(
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              print(deals[position].key + " clicked");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DealPageWidget(deals[position])),
              );
            },
            child: DealCard(deals[position], currentLocation)
          );
        },
        itemCount: deals.length,
      );
    }else {
      return Center (
        child: CircularProgressIndicator()
      );
    }
  }
}
