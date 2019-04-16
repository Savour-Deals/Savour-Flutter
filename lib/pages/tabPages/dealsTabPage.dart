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
  bool loaded = false;

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
    final _ = await SimplePermissions.requestPermission(Permission.AlwaysLocation);
    GeolocationStatus geolocationStatus = await geolocator.checkGeolocationPermissionStatus();
    final user = await FirebaseAuth.instance.currentUser();

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
        }
        geo.updateLocation(position.latitude, position.longitude, 80.0);
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
                    Deal newDeal = new Deal.fromMap(key, data, thisVendor);
                    newDeal.favorited = favorites.containsKey(newDeal.key);
                    var idx = deals.indexWhere((d1) => d1.key == newDeal.key);
                    if(idx<0){//add newDeal if it doesnt exit
                      deals.add(newDeal);
                      deals.sort((d1,d2) {
                        if(d1.isActive() == d2.isActive()){
                          return d1.vendor.distanceMilesFrom(lat, long).compareTo(d2.vendor.distanceMilesFrom(lat, long));
                        }else{
                          if(d1.isActive()){
                            return -1;
                          }
                          return 1;
                        }
                      });
                    }else{//otherwise, update the deal
                      deals[idx] = newDeal;
                      deals.sort((d1,d2) => d1.vendor.distanceMilesFrom(lat, long).compareTo(d2.vendor.distanceMilesFrom(lat, long)));
                    }
                  });
                });
              }
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
        physics: const AlwaysScrollableScrollPhysics (),
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              print(deals[position].key + " clicked");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DealPageWidget(deals[position], currentLocation)),
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
          child: CircularProgressIndicator()
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
