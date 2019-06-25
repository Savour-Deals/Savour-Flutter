part of tab_lib;

class FavoritesPageWidget extends StatefulWidget {
  final String text;

  FavoritesPageWidget(this.text);

  @override
  _FavoritesPageWidgetState createState() => _FavoritesPageWidgetState();
}

class _FavoritesPageWidgetState extends State<FavoritesPageWidget> {
  //Location variables
  final _locationService = Geolocator();
  Position currentLocation;

  //database variables 
  DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  DatabaseReference dealRef = FirebaseDatabase().reference().child("Deals");
  DatabaseReference favoritesRef;
  final geo = Geofire();
  bool first = true;
  bool loaded = false;

  List<Deal> deals = [];
  Map<String,Vendor> vendors = Map();
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    //Intializing geoFire
    geo.initialize("Vendors_Location");

    user = await FirebaseAuth.instance.currentUser();
    favoritesRef = FirebaseDatabase().reference()..child("Users").child(user.uid).child("favorites");
    try {
      var serviceStatus = await _locationService.checkGeolocationPermissionStatus();
      print("Service status: $serviceStatus");
      if (serviceStatus == GeolocationStatus.granted) {
        currentLocation = await _locationService.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.high)).listen((Position result) async {
          if (this.mounted){
            setState(() {
              currentLocation = result;
            });
          }
        });
        //Subscribe to this user's favorites, update page when changed
        FirebaseDatabase().reference().child("Users").child(user.uid).child("favorites").onValue.listen((datasnapshot) {
          if (this.mounted){
            if (datasnapshot.snapshot.value != null) {
              var favorites = new Map<String, String>.from(datasnapshot.snapshot.value);
              setState(() {
                deals.retainWhere((d) => favorites.containsKey(d.key));
              });
              for (var favorite in favorites.keys){
                if(deals.indexWhere((d)=> d.key == favorite) < 0){
                  createFavorite(favorite);
                }
              }
            }else{
              setState(() {
                loaded = true;
              });
            }
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


  void createFavorite(String favoriteKey) async {
    // print("deal added favoritesPage: " + favoriteKey);
    if (this.mounted){
      dealRef.child(favoriteKey).onValue.listen((dealEvent) async {
        if(dealEvent.snapshot.value != null){
          var vendorId = dealEvent.snapshot.value["vendor_id"];
          if (vendors.containsKey(vendorId)){
            setState(() {
              Deal newDeal = new Deal.fromSnapshot(dealEvent.snapshot, vendors[vendorId], user.uid);
              newDeal.favorited = true;
              var idx = deals.indexWhere((d)=> d.key == newDeal.key);
              if(idx < 0){
                deals.add(newDeal);
              }else{
                deals[idx] = newDeal;
              }
              deals.sort((d1,d2) { return dealSort(d1,d2); });
            });
          }else{
            geo.getLocation(vendorId).then((result) {
              if (result["error"]==null){
                var lat = result["lat"];
                var long = result["lng"];
                vendorRef.child(vendorId).once().then((vendorSnap) {
                  vendors[vendorId] = Vendor.fromSnapshot(vendorSnap, lat, long);
                  setState(() {
                    Deal newDeal = new Deal.fromSnapshot(dealEvent.snapshot, vendors[vendorId], user.uid);
                    newDeal.favorited = true;
                    var idx = deals.indexWhere((d)=> d.key == newDeal.key);
                    if(idx < 0){
                      deals.add(newDeal);
                    }else{
                      deals[idx] = newDeal;
                    }
                    deals.sort((d1,d2) { return dealSort(d1,d2); });
                  });
                });
              }
            });
          }
        }
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
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Savour Deals",
          style: whiteTitle,
        ),
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: Theme.of(context).bottomAppBarColor,//SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
          heroTag: "favTab",
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
    if (deals.length > 0){
      return ListView.builder(
        padding: EdgeInsets.all(0.0),
        physics: const AlwaysScrollableScrollPhysics (),
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              print(deals[position].key + " clicked");
              Navigator.push(
                context,
                platformPageRoute(
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
        return Center(child: Text("No favorites to show!"));
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