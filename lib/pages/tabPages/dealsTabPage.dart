part of tab_lib;

class DealsPageWidget extends StatefulWidget {
  final String text;

  DealsPageWidget(this.text);

  @override
  _DealsPageState createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPageWidget> {
  //Location variables
  final _locationService = Geolocator();
  Position currentLocation;

  //database variables 
  DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  DatabaseReference dealRef = FirebaseDatabase().reference().child("Deals");
  final geo = Geofire();
  bool loaded = false;
  FirebaseUser user;

  List<Vendor> vendors = [];
  Deals deals = Deals();
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
        FirebaseDatabase().reference().child("appData").child("filters").onValue.listen((datasnapshot) {
          if (this.mounted){
            if (datasnapshot.snapshot.value != null) {
              for (var filter in datasnapshot.snapshot.value){
                setState(() {
                  deals.addFilter(filter);
                });
              }
            }
          }
        });
        FirebaseDatabase().reference().child("Users").child(user.uid).child("favorites").onValue.listen((datasnapshot) {
          if (this.mounted){
            if (datasnapshot.snapshot.value != null) {
              setState(() {
                favorites = new Map<String, String>.from(datasnapshot.snapshot.value);
                for (var deal in deals.getAllDeals()){
                  deals.setFavoriteByKey(deal.key, favorites.containsKey(deal.key));
                }
              });
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
                    deals.addDeal(newDeal);
                  });
                });
              }
            });
          }
        })
      });
    }
  }

  // int dealSort(Deal d1, Deal d2){
  //   if(d1.isActive() && d2.isActive()){
  //     return d1.vendor.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude).compareTo(d2.vendor.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude));
  //   }else{
  //     if(d1.isActive()){
  //       return -1;
  //     }
  //     return 1;
  //   }
  // }

  void keyExited(dynamic data){
    // print("key exited dealsPage: " + data["key"]);
    if (this.mounted){
      setState(() {
        deals.removeDealWithVendorKey(data["key"]);
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
        trailingActions: <Widget>[
          FlatButton(
            child: Icon(Icons.account_balance_wallet, color: Colors.white,),
            color: Colors.transparent,
            // splashColor: Colors.transparent,
            onPressed: (){
              Navigator.push(context,
                platformPageRoute(
                  builder: (BuildContext context) {
                    return FavoritesPageWidget("Favorites Page");
                  },
                  fullscreenDialog: true
                )
              );
            },
          )
        ],
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: MyInheritedWidget.of(context).data.isDark? Theme.of(context).bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
          heroTag: "dealTab",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          backgroundColor: MyInheritedWidget.of(context).data.isDark? Theme.of(context).bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
        ),
      ),
      body: bodyWidget(),
    );
  }
  
  Widget bodyWidget(){
    if (deals.getAllDeals().length > 0){
      return Stack(
        children: <Widget>[
          ListView.builder(
            physics: const AlwaysScrollableScrollPhysics (),
            padding: EdgeInsets.only(top: 10.0),
            itemBuilder: (context, position) {
                return _buildCarousel(context, position);
            },
            itemCount: deals.filters.length+2,
          ),
          Align(
            alignment: Alignment(0.95, 0.95),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: SavourColorsMaterial.savourGreen,
              child: Icon(Icons.pin_drop, color: Colors.white,),
              onPressed: (){
                Navigator.push(context,
                  platformPageRoute(
                    builder: (BuildContext context) {
                      return new MapPageWidget("Map Page", this.vendors);
                    },
                    fullscreenDialog: true
                  )
                );
              },
            ),
          )
        ],
      );
    } else {
      if (loaded){
        return Center(child: Text("No deals nearby!"));
      }else{
        return Center (
          child: PlatformCircularProgressIndicator()
        );
      }
    }
  }

  Widget _buildCarousel(BuildContext context, int carouselIndex) {
    var carouselDeals = [];
    var carouselText = "";
    switch (carouselIndex) {
      case 0:
        carouselDeals = deals.getDealsByFilter(0);
        carouselText = deals.filters[0] + " Deals";
        break;
      case 1: 
        carouselDeals = deals.getDealsByValue();
        carouselText = "Deals By Value";
        break;
      case 2:
        carouselDeals = deals.getDealsByDistance(currentLocation);
        carouselText = "Deals By Distance";
        break;
      default:
        carouselDeals = deals.getDealsByFilter(carouselIndex-3);
        carouselText = deals.filters[carouselIndex-2] + " Deals";
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 15.0),
          width: MediaQuery.of(context).size.width,
          child: Text(carouselText, 
            textAlign: TextAlign.left, 
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 290,
          child: (carouselDeals.length <= 0)? Container():PageView.builder(
            // store this controller in a State to save the carousel scroll position
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (BuildContext context, int item) {
              return GestureDetector(
                onTap: () {
                  print(carouselDeals[item].key + " clicked");
                  Navigator.push(
                    context,
                    platformPageRoute(
                      builder: (context) => DealPageWidget(carouselDeals[item], currentLocation),
                    ),
                  );
                },
                child: DealCard(carouselDeals[item], currentLocation, false),
              );
            },
            itemCount: carouselDeals.length,  
          ),
        )
      ],
    );
  }
}
