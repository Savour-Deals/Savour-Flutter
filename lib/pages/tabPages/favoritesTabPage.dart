part of tab_lib;

class FavoritesPageWidget extends StatefulWidget {
  final String text;

  FavoritesPageWidget(this.text);

  @override
  _FavoritesPageWidgetState createState() => _FavoritesPageWidgetState();
}

class _FavoritesPageWidgetState extends State<FavoritesPageWidget> {
  DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  DatabaseReference dealRef = FirebaseDatabase().reference().child("Deals");
  DatabaseReference favoritesRef;
  final geo = Geofire();

  final geolocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10); 
  Position currentLocation;
  Permission permission;
  bool first = true;

  List<Deal> deals = [];
  Map<String,Vendor> vendors = Map();

  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    //Intializing geoFire
    geo.initialize("Vendors_Location");

    final user = await FirebaseAuth.instance.currentUser();
    favoritesRef = FirebaseDatabase().reference()..child("Users").child(user.uid).child("favorites");

    final _ = await SimplePermissions.requestPermission(Permission.AlwaysLocation);
    GeolocationStatus geolocationStatus = await geolocator.checkGeolocationPermissionStatus();

    if (geolocationStatus == GeolocationStatus.granted) {
      //get inital location and set up for geoquery
      currentLocation = await geolocator.getCurrentPosition();
      //Stream location and update query
      geolocator.getPositionStream(locationOptions).listen((Position position) async {
        if (this.mounted){
          setState(() {
            currentLocation = position;
          });
        }
      });
      FirebaseDatabase().reference()..child("Users").child(user.uid).child("favorites").onValue.listen((datasnapshot) {
        if (datasnapshot.snapshot.value != null) {
          var favorites = new Map<String, String>.from(datasnapshot.snapshot.value);
          deals.retainWhere((d) => favorites.containsKey(d.key));
          for (var favorite in favorites.keys){
            if(deals.indexWhere((d)=> d.key == favorite) < 0){
              createFavorite(favorite);
            }
          }
        }
      });
    }
  }


  void createFavorite(String favoriteKey) async {
    print("deal favorited favoritesPage: " + favoriteKey);
    if (this.mounted){
      dealRef.child(favoriteKey).onValue.listen((dealEvent) async {
        if(dealEvent.snapshot.value != null){
          var vendorId = dealEvent.snapshot.value["vendor_id"];
          if (vendors.containsKey(vendorId)){
            setState(() {
              Deal newDeal = new Deal.fromSnapshot(dealEvent.snapshot, vendors[vendorId]);
              deals.add(newDeal);
              deals.sort((d1,d2) => d1.vendor.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude).compareTo(d2.vendor.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude)));
            });
          }else{
            geo.getLocation(vendorId).then((result) {
              if (result["error"]==null){
                var lat = result["lat"];
                var long = result["lng"];
                vendorRef.child(vendorId).once().then((vendorSnap) {
                  vendors[vendorId] = Vendor.fromSnapshot(vendorSnap, lat, long);
                  setState(() {
                    Deal newDeal = new Deal.fromSnapshot(dealEvent.snapshot, vendors[vendorId]);
                    deals.add(newDeal);
                    deals.sort((d1,d2) => d1.vendor.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude).compareTo(d2.vendor.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude)));
                  });
                });
              }
            });
          }
        }
      });
    }
  }

  void removeFavorite(dynamic data){
    // print("deal unfavorited favoritesPage: " + data["key"]);
    if (this.mounted){
      setState(() {
        deals.removeWhere((deal) => deal.key == data["key"]);
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
                  builder: (context) => DealPageWidget(deals[position], currentLocation)),
              );
            },
            child: getCard(deals[position])
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

  Widget getCard(Deal deal){
    if (deal.isLive()){
      return DealCard(deal, currentLocation);
    }
    return Container();
  }
}