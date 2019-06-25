part of tab_lib;

class VendorsPageWidget extends StatefulWidget {
  final String text;

  VendorsPageWidget(this.text);

  @override
  _VendorsPageState createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPageWidget> {
  //Location variables
  final _locationService = Geolocator();
  Position currentLocation;

  //database variables 
  DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  final geo = Geofire();
  bool loaded = false;

  List<Vendor> vendors = [];
  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    //Intializing geoFire
    geo.initialize("Vendors_Location");
    try {
      var serviceStatus = await _locationService.checkGeolocationPermissionStatus();
      print("Service status: $serviceStatus");
      if (serviceStatus == GeolocationStatus.granted) {
        currentLocation = await _locationService.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          geo.queryAtLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
          geo.onKeyEntered.listen((data){
            keyEntered(data);
          });
          geo.onKeyExited.listen((data){
            keyExited(data);
          });
          _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.high)).listen((Position result) async {
            if (this.mounted){
              setState(() {
                currentLocation = result;
              });
              geo.updateLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
            }
          });
      } else {
        // bool serviceStatusResult = await _locationService.requestService();
        // print("Service status activated after request: $serviceStatusResult");
        // if(serviceStatusResult){
        //   initPlatform();
        // }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        print(e.message);
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        print(e.message);
      }
      currentLocation = null;
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
          var idx = vendors.indexWhere((d) => d.key == newVendor.key);
          if (idx < 0) {//Dont have vendor yet
            vendors.add(newVendor);
            vendors.sort((v1,v2) { return vendorSort(v1, v2); } );
          }else{//vendor present. Update vendor
            vendors[idx] = newVendor;
            vendors.sort((v1,v2) { return vendorSort(v1, v2); } );
          }
        })
      });
    }
  }

  int vendorSort(Vendor v1, Vendor v2){
    return v1.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude).compareTo(v2.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude));
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
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Savour Deals",
          style: whiteTitle,
        ),
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: Theme.of(context).bottomAppBarColor,//SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
          heroTag: "vendorTab",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          backgroundColor: Theme.of(context).bottomAppBarColor,//SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
        ),
      ),
      body: bodyWidget(),
    );
  }

  Widget bodyWidget(){
    if (vendors.length > 0) {
      return ListView.builder(
        padding: EdgeInsets.all(0.0),
        physics: const AlwaysScrollableScrollPhysics (),
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              print(vendors[position].name + " clicked");
              Navigator.push(
                context,
                platformPageRoute(
                  builder: (context) => VendorPageWidget(vendors[position])),
              );
            },
            child: VendorCard(vendors[position], currentLocation)
          );
        },
        itemCount: vendors.length,
      );
    }else {
      if (loaded){
        return Center(child: Text("No vendors nearby!"));
      }else{
        return Center (
          child: PlatformCircularProgressIndicator()
        );
      }
    }
  }
}
