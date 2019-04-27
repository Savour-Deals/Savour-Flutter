part of tab_lib;

class DealsPageWidget extends StatefulWidget {
  final String text;

  DealsPageWidget(this.text);

  @override
  _DealsPageState createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPageWidget> {
  //Location variables
  final _locationService = Location();
  StreamSubscription<LocationData> _locationSubscription;
  LocationData currentLocation;
  bool _permission = false;

  //database variables 
  DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  DatabaseReference dealRef = FirebaseDatabase().reference().child("Deals");
  final geo = Geofire();
  bool loaded = false;
  FirebaseUser user;

  List<Vendor> vendors = [];
  List<Deal> deals = [];
  Map<String,String> favorites = Map();

  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    //Intializing geoFire
    geo.initialize("Vendors_Location");
    user = await FirebaseAuth.instance.currentUser();
    await _locationService.changeSettings(accuracy: LocationAccuracy.HIGH, interval: 1000);
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
      if (serviceStatus) {
        _permission = await _locationService.requestPermission();
        print("Permission: $_permission");
        if (_permission) {
          currentLocation = await _locationService.getLocation();
          geo.queryAtLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
          geo.onKeyEntered.listen((data){
            keyEntered(data);
          });
          geo.onKeyExited.listen((data){
            keyExited(data);
          });
          _locationSubscription = _locationService.onLocationChanged().listen((LocationData result) async {
            if (this.mounted){
              setState(() {
                currentLocation = result;
              });
              geo.updateLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
            }
          });
          FirebaseDatabase().reference().child("Users").child(user.uid).child("favorites").onValue.listen((datasnapshot) {
            if (this.mounted){
              if (datasnapshot.snapshot.value != null) {
                setState(() {
                  favorites = new Map<String, String>.from(datasnapshot.snapshot.value);
                  for (var deal in deals){
                    if (favorites.containsKey(deal.key)){
                      deal.favorited = true;
                    }else{
                      deal.favorited = false;
                    }
                  }
                });
              }else{
                setState(() {
                  loaded = true;
                });
              }
            }
          });
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if(serviceStatusResult){
          initPlatform();
        }
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
            dealRef.orderByChild("vendor_id").equalTo(newVendor.key).onValue.listen((dealEvent) {
              if (this.mounted){
                setState(() {
                  Map<String, dynamic> dealDataMap = new Map<String, dynamic>.from(dealEvent.snapshot.value);
                  dealDataMap.forEach((key,data){
                    var thisVendor = vendors.firstWhere((v)=> v.key == data["vendor_id"]);
                    Deal newDeal = new Deal.fromMap(key, data, thisVendor, user.uid);
                    newDeal.favorited = favorites.containsKey(newDeal.key);
                    var idx = deals.indexWhere((d1) => d1.key == newDeal.key);
                    if(idx<0){//add newDeal if it doesnt exit
                      deals.add(newDeal);
                    }else{//otherwise, update the deal
                      deals[idx] = newDeal;
                    }
                    deals.sort((d1,d2) {return dealSort(d1,d2);});
                  });
                });
              }
            });
          }
        })
      });
    }
  }

  int dealSort(Deal d1, Deal d2){
    if(d1.isActive() && d2.isActive()){
      return d1.vendor.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude).compareTo(d2.vendor.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude));
    }else{
      if(d1.isActive()){
        return -1;
      }
      return 1;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Savour Deals",
          style: whiteTitle,
        ),
        brightness: Brightness.dark,
        backgroundColor: SavourColorsMaterial.savourGreen,
      ),
      body: bodyWidget(),
    );
  }
  
  Widget bodyWidget(){
    if (deals.length > 0){
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics (),
        padding: EdgeInsets.all(0.0),
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              print(deals[position].key + " clicked");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DealPageWidget(deals[position], currentLocation),
                ),
              );
            },
            child: getCard(deals[position])
          );
        },
        itemCount: deals.length,
      );
    }else {
      if (loaded){
        return Center(child: Text("No deals nearby!"));
      }else{
        return Center (
          child: PlatformCircularProgressIndicator()
        );
      }
    }
  }

  Widget getCard(Deal deal){
    if (deal.isLive()){
      return DealCard(deal, currentLocation);
    }
    return Container();
  }
}
