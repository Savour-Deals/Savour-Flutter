part of tab_lib;

class VendorsPageWidget extends StatefulWidget {
  final String text;

  VendorsPageWidget(this.text);

  @override
  _VendorsPageState createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPageWidget> {
  DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  final geolocator = Geolocator();
  final geo = Geofire();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  Permission permission;
  bool first = true;
  Position currentLocation;


  List<Vendor> vendors = [];
  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    //Intializing geoFire
    geo.initialize("Vendors_Location");
    final _ =
        await SimplePermissions.requestPermission(Permission.AlwaysLocation);
    GeolocationStatus geolocationStatus =
        await geolocator.checkGeolocationPermissionStatus();

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
        if (this.mounted){
          setState(() {
            currentLocation = position;
          });
          geo.updateLocation(position.latitude, position.longitude, 80.0);
        }
      });
    }
  }

  void keyEntered(dynamic data) {
    // print("key entered vendorsPage: " + data["key"]);
    var lat = data["lat"];
    var long = data["long"];
    if (this.mounted){
      vendorRef.child(data["key"]).onValue.listen((event) => {
        setState(() {
          Vendor newVendor = Vendor.fromSnapshot(event.snapshot, lat, long);
          if (!vendors.contains(newVendor)) {
            vendors.add(newVendor);
            vendors.sort((v1,v2) => v1.distanceMilesFrom(lat, long).compareTo(v2.distanceMilesFrom(lat, long)));
          }
        })
      });
    }
  }

  void keyExited(dynamic data) {
    // print("key exited vendorsPage: " + data["key"]);
    if (this.mounted){
      setState(() {
        vendors.removeWhere((vendor) => vendor.key == data["key"]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vendors.length > 0) {
      return ListView.builder(
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              print(vendors[position].name + " clicked");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VendorPageWidget(vendors[position])),
              );
            },
            child: VendorCard(vendors[position], currentLocation)
          );
        },
        itemCount: vendors.length,
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
