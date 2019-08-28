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
          currentLocation = await _locationService.getLastKnownPosition(desiredAccuracy: LocationAccuracy.medium);
          geo.queryAtLocation(currentLocation.latitude, currentLocation.longitude, 80.0);
          geo.onKeyEntered.listen((data){
            keyEntered(data);
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
            var route = MaterialPageRoute(builder: (_) => page, maintainState: false, fullscreenDialog: true);
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
                  var route = MaterialPageRoute(builder: (_) => page, maintainState: false);
                  Navigator.push(context,route);
                },
                child: VendorCard(vendors[position], currentLocation)
              );
            },
            itemCount: vendors.length,
          ),
          Align(
            alignment: Alignment(0.90, 0.85),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: SavourColorsMaterial.savourGreen,
              child: Icon(Icons.pin_drop, color: Colors.white,),
              onPressed: () async {
                var page = await buildPageAsync(PageType.mapPage);
                var route = MaterialPageRoute(builder: (_) => page, maintainState: false, fullscreenDialog: true);
                Navigator.push(context,route);
              },
            ),
          )
        ],
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

  Future<Widget> buildPageAsync(PageType pageType, {position: int}) async {
    return Future.microtask(() {
      switch (pageType) {
        case PageType.mapPage:
          return MapPageWidget("Map Page", this.vendors);
          break;
        case PageType.searchPage:
          return SearchPageWidget(vendors: vendors,location: currentLocation,);
          break;
        case PageType.vendorPage:
          return VendorPageWidget(vendors[position]);
          break;
      }
    });
}
}
