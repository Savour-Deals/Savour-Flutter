part of tab_lib;

class VendorsPageWidget extends StatefulWidget {
  final String text;

  VendorsPageWidget(this.text);

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

  //database variables 
  DatabaseReference vendorRef = FirebaseDatabase().reference().child("Vendors");
  final geo = Geofire();
  bool loaded = false;

  List<Vendor> vendors = [];

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
    try {
      var serviceStatus = await _locationService.checkGeolocationPermissionStatus();
      if (serviceStatus == GeolocationStatus.granted) {
        currentLocation = await _locationService.getLastKnownPosition(desiredAccuracy: LocationAccuracy.medium); //this may be null! Thats ok!
        geo.queryAtLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
        geo.onObserveReady.listen((ready){
          setState(() {
            geoFireReady = true;
          });
        });
        geo.onKeyEntered.listen((data){
          setState(() {
            keyEnteredCounter++;
          });          keyEntered(data);
        });
        geo.onKeyExited.listen((data){
          keyExited(data);
        });
        _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.medium, distanceFilter: 400)).listen((Position result) async {
          if (this.mounted){
            setState(() {
              currentLocation = result;
            });
            geo.updateLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
          }
        });
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  _startLoadingTimer(){
    //If we have waited for +10s and geofire has not loaded, tell user to check their interet!
    const tenSec = const Duration(seconds: 10);
    Timer.periodic(
      tenSec,
      (Timer timer) => setState(
        () {
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
        },
      ),
    );
  }

  void keyEntered(dynamic data) {
    // print("key entered vendorsPage: " + data["key"]);
    var lat = data["lat"];
    var long = data["long"];
    if (this.mounted){
      vendorRef.child(data["key"]).onValue.listen((event) => {
        if (event.snapshot != null){
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
        }
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
            var route = MaterialPageRoute(builder: (_) => page, fullscreenDialog: true);
            Navigator.push(context,route);
          },
        ),
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Brightness.dark,
          heroTag: "vendorTab",
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
    if (vendors.length > 0) {
      return Stack(
        children: <Widget>[
          ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(0.0),
            // physics: const AlwaysScrollableScrollPhysics (),
            itemBuilder: (context, position) {
              return GestureDetector(
                onTap: () async {
                  print(vendors[position].name + " clicked");
                  var page = await buildPageAsync(PageType.vendorPage, position: position);
                  var route = MaterialPageRoute(builder: (_) => page);
                  Navigator.push(context,route);
                },
                child: VendorCard(vendors[position], currentLocation)
              );
            },
            itemCount: vendors.length,
          ),
          Align(
            alignment: Alignment(-0.90, 0.90),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: SavourColorsMaterial.savourGreen,
              child: Icon(Icons.pin_drop, color: Colors.white,),
              onPressed: () async {
                var page = await buildPageAsync(PageType.mapPage);
                var route = MaterialPageRoute(builder: (_) => page, fullscreenDialog: true);
                Navigator.push(context,route);
              },
            ),
          )
        ],
      );
    }else {
      if (geoFireReady && keyEnteredCounter == 0){
        //If geofire has loaded but we got no deals, tell user no deals
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
                  AutoSizeText(
                    "Loading Vendors...",
                    maxFontSize: 22,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width*0.5,
              height: MediaQuery.of(context).size.width*0.5,
            ),
          )
        );
      }
    }
  }

  Future<Widget> buildPageAsync(PageType pageType, {position: int}) async {
    return Future.microtask(() async {
      switch (pageType) {
        case PageType.mapPage:
          return MapPageWidget("Map Page", this.vendors, currentLocation);
          break;
        case PageType.searchPage:
          return SearchPageWidget(vendors: vendors,location: currentLocation);
          break;
        case PageType.vendorPage:
          return VendorPageWidget(vendors[position], currentLocation);
          break;
        default:
          return null;
      }
    });
}
}
