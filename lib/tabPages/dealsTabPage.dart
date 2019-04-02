part of tab_lib;

class DealsPageWidget extends StatefulWidget {
  final String text;

  DealsPageWidget(this.text);

  @override
  _DealsPageState createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPageWidget> {
  var geolocator = Geolocator();
  var geo = Geofire();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10); 
  Permission permission;
  List<String> vendorKeys = [];
  bool first = true;

  // Vendor vendors;
  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    //Intializing geoFire
    geo.initialize("Vendors_Location", (result) => {keyEntered(result)}, (result) => {keyExited(result)});
    final _ = await SimplePermissions.requestPermission(Permission.AlwaysLocation);
    GeolocationStatus geolocationStatus  = await geolocator.checkGeolocationPermissionStatus();

    if (geolocationStatus == GeolocationStatus.granted){
      //get inital location and set up for geoquery
      var location = await geolocator.getCurrentPosition();
      geo.queryAtLocation(location.latitude, location.longitude, 80.0);

      //Stream location and update query
      geolocator.getPositionStream(locationOptions).listen((Position position) async { 
        print(position == null ? 'Unknown' : "Location Updated: " + position.latitude.toString() + ', ' + position.longitude.toString());
        geo.updateLocation(position.latitude, position.longitude, 80.0);
      });
    }
  }

  void keyEntered(dynamic data){
    print("key entered: " + data["key"]);
    setState(() {
      vendorKeys.add(data["key"]);
    });
  }

  void keyExited(dynamic data){
    print("key exited: " + data["key"]);
    setState(() {
      vendorKeys.remove(data["key"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vendorKeys.length > 0){
      return ListView.builder(
        itemBuilder: (context, position) {
          return Card(
            child: Text(vendorKeys[position]),
          );
        },
        itemCount: vendorKeys.length,
      );
    }else {
      return Center (
        child: CircularProgressIndicator()
      );
    }
  }
}
