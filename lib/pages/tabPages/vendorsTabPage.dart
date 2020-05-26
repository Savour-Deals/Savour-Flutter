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

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  VendorBloc _vendorsBloc;

  @override
  void initState() {
    super.initState();
    initPlatform();
  }

  void initPlatform() async {
    Position currentLocation;
    _vendorsBloc = BlocProvider.of<VendorBloc>(context);
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

    _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.medium, distanceFilter: 400)).listen((Position result) async {
      if (currentLocation == null){
        _vendorsBloc.add(FetchVendors(location: currentLocation));
      }else{
        _vendorsBloc.add(UpdateVendorsLocation(location: currentLocation));
      }
      currentLocation = result;
    });//.cancel();
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

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return BlocBuilder<VendorBloc, VendorState>(
      builder: (context, state) {
        return StreamBuilder<Vendors>(
          stream: _vendorsBloc.vendorRepo.getVendorStream(),
          initialData: Vendors(),
          builder: (BuildContext context, AsyncSnapshot<Vendors> snap) {
            Vendors vendors = snap.data;
            return PlatformScaffold(
              appBar: PlatformAppBar(
                title: Image.asset("images/Savour_White.png"),
                leading: FlatButton(
                  child: Icon(Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    var route = platformPageRoute(
                      context: context,
                      settings: RouteSettings(name: "SearchPage"),
                      builder: (_) => SearchPageWidget(vendors: vendors.getVendorList(), location: state.location), 
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
              body: Material(child: _buildBody(state, vendors)),
            );
          }
        );
      }
    );
  }

  Widget _buildBody(VendorState state, Vendors vendors){
    if (state is VendorUninitialized) {
      return Loading(text: "Loading Vendors...");
    } else if (state is VendorError) {
      return TextPage(text: "An error occured.");
    } else if (state is VendorLoaded) {
      if (vendors!= null && vendors.count > 0){
        final vendorList = vendors.getVendorList();
        return Stack(
          children: <Widget>[
            ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(0.0),
              // physics: const AlwaysScrollableScrollPhysics (),
              itemBuilder: (context, position) {
                return GestureDetector(
                  onTap: () async {
                    print(vendorList[position].name + " clicked");
                    var route = platformPageRoute(
                      context: context,
                      settings: RouteSettings(name: "VendorPage"),
                      builder: (_) => VendorPageWidget(vendorList[position], state.location), 
                    );
                    Navigator.push(context,route);
                  },
                  child: VendorCard(vendorList[position], state.location),
                );
              },
              itemCount: vendors.count,
            ),
            Align(
              alignment: Alignment(-0.90, 0.90),
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: SavourColorsMaterial.savourGreen,
                child: Icon(Icons.pin_drop, color: Colors.white,),
                onPressed: () async {
                  var route = platformPageRoute(
                    context: context,
                    settings: RouteSettings(name: "MapPage"),
                    builder: (_) => MapPageWidget(vendorList, state.location), 
                    fullscreenDialog: true, 
                  );
                  Navigator.push(context,route);
                },
              ),
            )
          ],
        );
      } else if (vendors.isLoading) {
        return Loading(text: "Loading Vendors...");
      }
      return TextPage(text: "No Vendors Nearby!");
    }
    return TextPage(text: "An error ocurred");
  }
}
