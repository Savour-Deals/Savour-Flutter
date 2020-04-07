part of tab_lib;

class VendorsPageWidget extends StatefulWidget {
  VendorsPageWidget();

  @override
  _VendorsPageState createState() => _VendorsPageState();
}

enum PageType {
  mapPage, vendorPage, searchPage
}

class _VendorsPageState extends State<VendorsPageWidget> {
  //Location variables
  final _locationService = Geolocator();
  Position currentLocation;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  VendorBloc _vendorsBloc;


  //database variables 
  // DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  // final geo = Geofire();
  // bool loaded = false;

  // List<Vendor> vendors = [];

  // bool geoFireReady = false;
  // int keyEnteredCounter = 0;
  
  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    _vendorsBloc = BlocProvider.of<VendorBloc>(context);
    //start loading timer :: 10s, if not done loading by then, display toast
    // _startLoadingTimer();
    //Intializing geoFire
    // geo.initialize("Vendors_Location");
    try {
      var serviceStatus = await _locationService.checkGeolocationPermissionStatus();
      if (serviceStatus == GeolocationStatus.granted) {
        currentLocation = await _locationService.getLastKnownPosition(desiredAccuracy: LocationAccuracy.medium); //this may be null! Thats ok!
      }
    } on PlatformException catch (e) {
      print(e.message);
    }

    if (currentLocation != null){
      //If we have the location, fire off the query, otherwise we will have to wait for the stream
      _vendorsBloc.add(FetchVendors(location: currentLocation));
    }
    // geo.onObserveReady.listen((ready){
    //   if(this.mounted){
    //     setState(() {
    //       geoFireReady = true;
    //     });
    //   }
    // });
    // geo.onKeyEntered.listen((data){
    //   if(this.mounted){
    //     setState(() {
    //       keyEnteredCounter++;
    //     });          
    //     keyEntered(data);
    //   }
    // });
    // geo.onKeyExited.listen((data){
    //   if(this.mounted){
    //     keyExited(data);
    //   }
    // });
    _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.medium, distanceFilter: 400)).listen((Position result) async {
      // if (this.mounted){
      //   setState(() {
      //     currentLocation = result;
      //   });
      //   if (geo.geoQueryActive){
      //     //Query already running, update location
      //     geo.updateLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
      //   }else{
      //     // this is our first location update. Fire off the geoquery
      //     geo.queryAtLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
      //   }
      // }
      _vendorsBloc.add(FetchVendors(location: currentLocation));
    }).cancel();
  }

  _startLoadingTimer(){
    //If we have waited for +10s and geofire has not loaded, tell user to check their interet!
    // const tenSec = const Duration(seconds: 10);
    // Timer.periodic(
    //   tenSec,
    //   (Timer timer) {
    //     if(this.mounted){
    //       setState(() {
    //         timer.cancel();
    //         if(!geoFireReady){
    //           Fluttertoast.showToast(
    //             msg: "We seem to be taking a while to load. Check your internet connection to make sure you're online.",
    //             toastLength: Toast.LENGTH_LONG,
    //             gravity: ToastGravity.BOTTOM,
    //             timeInSecForIos: 8,
    //             backgroundColor: Colors.black.withOpacity(0.5),
    //           );
    //         }
    //       });
    //     }
    //   }
    // );
  }

  // void keyEntered(dynamic data) {
  //   // print("key entered vendorsPage: " + data["key"]);
  //   var lat = data["lat"];
  //   var long = data["long"];
  //   if (this.mounted){
  //     vendorRef.child(data["key"]).onValue.listen((event) => {
  //       if (event.snapshot != null){
  //         setState(() {
  //           Vendor newVendor = Vendor.fromSnapshot(event.snapshot, lat, long);
  //           var idx = vendors.indexWhere((d) => d.key == newVendor.key);
  //           if (idx < 0) {//Dont have vendor yet
  //             vendors.add(newVendor);
  //             vendors.sort((v1,v2) { return vendorSort(v1, v2); } );
  //           }else{//vendor present. Update vendor
  //             vendors[idx] = newVendor;
  //             vendors.sort((v1,v2) { return vendorSort(v1, v2); } );
  //           }
  //         })
  //       }
  //     });
  //   }
  // }

  // int vendorSort(Vendor v1, Vendor v2){
  //   return v1.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude).compareTo(v2.distanceMilesFrom(currentLocation.latitude, currentLocation.longitude));
  // }

  // void keyExited(dynamic data) {
  //   // print("key exited vendorsPage: " + data["key"]);
  //   if (this.mounted){
  //     setState(() {
  //       vendors.removeWhere((vendor) => vendor.key == data["key"]);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        leading: FlatButton(
          child: Icon(Icons.search,
            color: Colors.white,
          ),
          onPressed: () async {
            var page = await buildPageAsync(PageType.searchPage);
            var route = platformPageRoute(
              context: context,
              settings: RouteSettings(name: "SearchPage"),
              builder: (_) => page, 
              fullscreenDialog: true, 
            );
            Navigator.push(context,route);
          },
        ),
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: ColorWithFakeLuminance(theme.appBarTheme.color, withLightLuminance: true),
          heroTag: "vendorTab",
          transitionBetweenRoutes: false,
        ),
      ),
      body: Material(child: bodyWidget()),
    );
  }

  Widget bodyWidget(){
    return BlocBuilder<VendorBloc, VendorState>(
      builder: (context, state) {
        if (state is VendorUninitialized || state is VendorLoading) {
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
                      "Loading Vendors...",
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
        if (state is VendorError) {
          return Center(
            child: Text('An error has occured'),
          );
        }
        if (state is VendorLoaded) {
          return Stack(
            children: <Widget>[
              StreamBuilder<List<VendorCacheItem>>(
                stream: state.vendorStream,
                builder: (BuildContext context, AsyncSnapshot<List<VendorCacheItem>> vendorList) {
                  if (vendorList.data != null && vendorList.data.length > 0){
                    return ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(0.0),
                      // physics: const AlwaysScrollableScrollPhysics (),
                      itemBuilder: (context, position) {
                        final Vendor vendor = vendorList.data[position].vendor;
                        return GestureDetector(
                          onTap: () async {
                            print(vendor.name + " clicked");
                            var route = platformPageRoute(
                              context: context,
                              settings: RouteSettings(name: "VendorPage"),
                              builder: (_) => VendorPageWidget(vendor, currentLocation), 
                            );
                            Navigator.push(context,route);
                          },
                          child: VendorCard(vendor, currentLocation)
                        );
                      },
                      itemCount: vendorList.data.length,
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: Center(
                        child: AutoSizeText(
                          "No vendors nearby!", 
                          minFontSize: 15,
                          maxFontSize: 22,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ),
                    );
                  }
                },
              ),
              Align(
                alignment: Alignment(-0.90, 0.90),
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: SavourColorsMaterial.savourGreen,
                  child: Icon(Icons.pin_drop, color: Colors.white,),
                  onPressed: () async {
                    // var route = platformPageRoute(
                    //   context: context,
                    //   settings: RouteSettings(name: "MapPage"),
                    //   builder: (_) => SearchPageWidget(vendors: state.vendorStream.,location: currentLocation), 
                    //   fullscreenDialog: true, 
                    // );
                    // Navigator.push(context,route);
                  },
                ),
              )
            ],
          );
        } else {
          return Center(
            child: Text("failed to match a state"),
          );
        }
      }
    );
  }

  Future<Widget> buildPageAsync(PageType pageType, {position: int}) async {
    return Future.microtask(() async {
      // switch (pageType) {
      //   case PageType.mapPage:
      //     return MapPageWidget("Map Page", this.vendors, currentLocation);
      //     break;
      //   case PageType.searchPage:
      //     return SearchPageWidget(vendors: vendors,location: currentLocation);
      //     break;
      //   case PageType.vendorPage:
      //     return VendorPageWidget(vendors[position], currentLocation);
      //     break;
      //   default:
      //     return null;
      // }
    });
}
}
