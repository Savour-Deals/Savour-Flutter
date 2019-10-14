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

  //Declare contextual variables
  AppState appState;
  NotificationData notificationData;
  ThemeData theme;

  //database variables 
  DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  DatabaseReference dealRef = FirebaseDatabase().reference().child("Deals");
  final geo = Geofire();
  FirebaseUser user;

  List<Vendor> vendors = [];
  Deals deals = Deals();
  Map<String,String> favorites = Map();
  
  bool geoFireReady = false;
  int keyEnteredCounter = 0;

  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    //start loading timer :: 10s, if not done loading by then, display toast
    _startLoadingTimer();
    //Intializing geoFire
    geo.initialize("Vendors_Location");
    user = await FirebaseAuth.instance.currentUser();
    try {
      var serviceStatus = await _locationService.checkGeolocationPermissionStatus();
      if (serviceStatus == GeolocationStatus.granted) {
        currentLocation = await _locationService.getLastKnownPosition(desiredAccuracy: LocationAccuracy.medium); //this may be null! Thats ok!
        if(currentLocation != null){
          deals.setLocation(currentLocation);
        }
      }
    } on PlatformException catch (e) {
      print(e.message);
    }

    if (currentLocation != null){
      //If we have the location, fire off the query, otherwise we will have to wait for the stream
      geo.queryAtLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
    }
    geo.onObserveReady.listen((ready){
      if(this.mounted){
        setState(() {
          geoFireReady = true;
        });      
      }
    });
    geo.onKeyEntered.listen((data){
      if (this.mounted){
        setState(() {
          keyEnteredCounter++;
        });
        keyEntered(data);
      }
    });
    geo.onKeyExited.listen((data){
      if (this.mounted){
        keyExited(data);  
      }
    });
    _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.medium, distanceFilter: 400)).listen((Position result) async {
      if (this.mounted){
        setState(() {
          currentLocation = result;
          deals.setLocation(currentLocation);
        });
        if (geo.geoQueryActive){
          //Query already running, update location
          geo.updateLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
        }else{
          // this is our first location update. Fire off the geoquery
          geo.queryAtLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
        }      
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
        }
      }
    });
  }

  _startLoadingTimer(){
    //If we have waited for +10s and geofire has not loaded, tell user to check their interet!
    const tenSec = const Duration(seconds: 10);
    Timer.periodic(
      tenSec,
      (Timer timer) {
        if(this.mounted){
          setState(() {
            timer.cancel();
            if(!geoFireReady){
              Fluttertoast.showToast(
                msg: "We seem to be taking a while to load. Check your internet connection to make sure you're online.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 8,
                backgroundColor: Colors.black.withOpacity(0.5),
              );
            }
          });
        }
      }
    );
  }

  void keyEntered(dynamic data){
    // print("key entered dealsPage: " + data["key"]);
    var lat = data["lat"];
    var long = data["long"];
    if (this.mounted){
      vendorRef.child(data["key"]).onValue.listen((vendorEvent) => {
        if (vendorEvent.snapshot != null){
          setState(() {
            Vendor newVendor = Vendor.fromSnapshot(vendorEvent.snapshot, lat, long);
            if (!vendors.contains(newVendor)){
              vendors.add(newVendor); 
              dealRef.orderByChild("vendor_id").equalTo(newVendor.key).onValue.listen((dealEvent) {
                if (this.mounted && dealEvent.snapshot != null){
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
        }
      });
    }
  }

  void keyExited(dynamic data){
    // print("key exited dealsPage: " + data["key"]);
    if (this.mounted){
      setState(() {
        deals.removeDealWithVendorKey(data["key"]);
      });
    }
  }

  Future<Deal> getDeal(String dealID) async {
    if(!deals.containsDeal(dealID)){
      return await FirebaseDatabase().reference().child("Deals").child(dealID).once().then((dealSnap) async {
        var newVendor;
        newVendor = await getVendor(dealSnap.value["vendor_id"]);        
        var newDeal = Deal.fromSnapshot(dealSnap, newVendor, user.uid);
        deals.addDeal(newDeal);//save it for future use
        return newDeal;
      });
    }
    //If the deal is already here, send it back
    return deals.getDealByKey(dealID);
  }

  Future<Vendor> getVendor(String vendorID) async {
    if(vendors.indexWhere((vendor) => vendor.key == vendorID) < 0){
      return await FirebaseDatabase().reference().child("Vendors").child(vendorID).once().then((vendorSnap) {
        var newVendor = Vendor.fromSnapshot(vendorSnap, currentLocation.latitude, currentLocation.longitude);
        vendors.add(newVendor);
        return newVendor;//save it for future use
      });
    }
    //If the vendor is already here, send it back
    return vendors.firstWhere((vendor) => vendor.key == vendorID);
  }

  void displayNotiDeal() async {
    if (notificationData.isNotiDealPresent){
      Deal notiDeal = await getDeal(notificationData.consumeNotiDealID);
      print("DealID: ${notiDeal.key}");
      Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (context) => DealPageWidget(
            deal: notiDeal,
            location: currentLocation
          ),
        ),
      );
    }else{
      print("No DealID");
    }
  }
  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    notificationData = Provider.of<NotificationData>(context);
    if (notificationData.isNotiDealPresent) displayNotiDeal(); //check to make sure we already are pending a notification deal
    notificationData.addListener(() => displayNotiDeal());//if not, listen for changes!
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        leading: FlatButton(
          child: Icon(Icons.search,
            color: Colors.white,
          ),
          onPressed: (){
            Navigator.push(context,
              platformPageRoute(
                context: context,
                builder: (BuildContext context) {
                  return SearchPageWidget(deals: deals, location: currentLocation,);
                },
                fullscreenDialog: true
              )
            );
          },
        ),
        title: Image.asset("images/Savour_White.png"),
        trailingActions: <Widget>[
          FlatButton(
            child: Image.asset('images/wallet_filled.png',
              color: Colors.white,
              width: 30,
              height: 30,
            ),
            color: Colors.transparent,
            onPressed: (){
              Navigator.push(context,
                platformPageRoute(
                  context: context,
                  builder: (BuildContext context) {
                    return WalletPageWidget(deals,vendors);
                  },
                  fullscreenDialog: true
                )
              );
            },
          )
        ],
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: ColorWithFakeLuminance(appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen, withLightLuminance: true),
          heroTag: "dealTab",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
        ),
      ),
      body: bodyWidget(),
    );
  }
  
  Widget bodyWidget(){
    if (deals.getAllDeals().length > 0){
      Fluttertoast.cancel();
      return Stack(
        children: <Widget>[
          ListView.builder(
            physics: const AlwaysScrollableScrollPhysics (),
            padding: EdgeInsets.only(top: 10.0),
            itemBuilder: (context, position) {
              List<Deal> filterDeals = [];
              var filterText = "";
              switch (position) {
                case 0:
                  filterDeals = deals.getDealsByFilter(0);
                  filterText = deals.filters[0] + " Deals";
                  break;
                case 1: 
                  filterDeals = deals.getDealsByValue();
                  filterText = "Deals By Value";
                  break;
                case 2:
                  filterDeals = deals.getDealsByDistance();
                  filterText = "Deals By Distance";
                  break;
                default:
                  filterDeals = deals.getDealsByFilter(position-2);
                  filterText = deals.filters[position-2] + " Deals";
              }
              return (filterDeals.length > 0)? _buildCarousel(context, position, filterDeals, filterText): Container();
            },
            itemCount: deals.filters.length+2,
          ),
          Align(
            alignment: Alignment(-0.90, 0.90),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: SavourColorsMaterial.savourGreen,
              child: Icon(Icons.pin_drop, color: Colors.white,),
              onPressed: (){
                Navigator.push(context,
                  platformPageRoute(
                    context: context,
                    builder: (BuildContext context) {
                      return new MapPageWidget("Map Page", this.vendors, currentLocation);
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
      if (geoFireReady && keyEnteredCounter == 0){
        //If geofire has loaded but we got no deals, tell user no deals
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: AutoSizeText(
              "No deals nearby!", 
              minFontSize: 15,
              maxFontSize: 22,
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ),
        );
      }else{
        //Geofire not ready, show loading
        return Center (
          child:  ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PlatformCircularProgressIndicator(),
                  Container(height: 10),
                  AutoSizeText(
                    "Loading Deals...",
                    maxFontSize: 22,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width*0.5,
              height: MediaQuery.of(context).size.width*0.4,
            ),
          )
        );
      }
    }
  }

  Widget _buildCarousel(BuildContext context, int carouselIndex, List<Deal> carouselDeals, String carouselText) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 15.0),
          width: MediaQuery.of(context).size.width,
          child: Text(carouselText, 
            textAlign: TextAlign.left, 
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: (carouselDeals.length <= 0)? Container():PageView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            // store this controller in a State to save the carousel scroll position
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (BuildContext context, int item) {
              return GestureDetector(
                onTap: () {
                  print(carouselDeals[item].key + " clicked");
                  Navigator.push(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (context) => DealPageWidget(
                        deal: carouselDeals[item], 
                        location: currentLocation
                      ),
                    ),
                  );
                },
                child: DealCard(
                  deal: carouselDeals[item], 
                  location: currentLocation, 
                  type: DealCardType.medium,
                ),
              );
            },
            itemCount: carouselDeals.length,  
          ),
        )
      ],
    );
  }
}


