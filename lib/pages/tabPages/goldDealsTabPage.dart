part of tab_lib;

class GoldDealsPageWidget extends StatefulWidget {
  GoldDealsPageWidget();

  @override
  _GoldDealsPageState createState() => _GoldDealsPageState();
}

class _GoldDealsPageState extends State<GoldDealsPageWidget> {
  //Location variables
  Position currentLocation;

  //Declare contextual variables
  AppState appState;
  NotificationData notificationData;
  ThemeData theme;

  User user;

  SharedPreferences prefs;

  DealsBloc _dealsBloc;

  @override
  void initState() {
    super.initState();
    _dealsBloc = BlocProvider.of<DealsBloc>(context);
    initPlatform();
  }

  void initPlatform() async {
    //Intializing geoFire
    // geo.initialize("Vendors_Location");
    user = FirebaseAuth.instance.currentUser;
    try {
      var serviceStatus = await checkPermission();
      if (serviceStatus == LocationPermission.always || serviceStatus == LocationPermission.whileInUse) {
        currentLocation = await getLastKnownPosition(); //this may be null! Thats ok!
      }
    } on PlatformException catch (e) {
      print(e.message);
    }

    if (currentLocation != null){
      //If we have the location, fire off the query, otherwise we will have to wait for the stream
      _dealsBloc.add(FetchDeals(location: currentLocation));
    }

    getPositionStream(desiredAccuracy: LocationAccuracy.medium, distanceFilter: 400).listen((Position result) async {
      currentLocation = result;
      if (currentLocation == null){
        _dealsBloc.add(FetchDeals(location: currentLocation));
      }else{
        _dealsBloc.add(UpdateDealsLocation(location: currentLocation));
      }
    });//.cancel();
  }


  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return BlocBuilder<DealsBloc, DealsState>(
      builder: (context, state) {
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
                    settings: RouteSettings(name: "SearchPage"),
                    builder: (BuildContext context) {
                      return _searchPage(state);
                    },
                    fullscreenDialog: true
                  )
                );
              },
            ),
            title: SavourTitle(),
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
                      settings: RouteSettings(name: "WalletPage"),
                      builder: (BuildContext context) {
                        return BlocProvider<WalletBloc>(
                          create: (context) => WalletBloc(),
                          child:  WalletPageWidget()
                        );
                      },
                      fullscreenDialog: true
                    )
                  );
                },
              ),
            ],
            cupertino: (_,__) => CupertinoNavigationBarData(
              backgroundColor: ColorWithFakeLuminance(theme.appBarTheme.color, withLightLuminance: true),
              heroTag: "goldDealTab",
              transitionBetweenRoutes: false,
            ),
            material: (_,__) => MaterialAppBarData(
              centerTitle: true,
            ),
          ),
          body: Material(child: bodyWidget(state)),
        );
      },
    );
  }

  Widget _searchPage(DealsState state){
    if (state is DealsLoaded) {
      return StreamBuilder<Deals>(
        stream: state.dealStream,
        initialData: globals.dealsApiProvider.deals,
        builder: (BuildContext context, AsyncSnapshot<Deals> snap) {
          Deals deals = snap.data;
          return SearchPageWidget(deals: deals, location: state.location);  
        }
      );
    }
    return SearchPageWidget(deals: Deals(), location: state.location); 
  }
  
  Widget bodyWidget(DealsState state){
    if (state is DealsUninitialized) {
      return Loading(text: "Loading Deals...");
    } else if (state is DealsError) {
      return TextPage(text: "An error occured.");
    } else if (state is DealsLoaded) {
      return StreamBuilder<List<dynamic>>(
        stream: CombineLatestStream.combine2(
          state.dealStream,
          state.vendorStream,
          (deals, vendors) {
            return [deals, vendors];
          }
        ),
        initialData: [globals.dealsApiProvider.deals, globals.vendorApiProvider.vendors],
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snap) {
          final  Deals deals = snap.data[0] as Deals;
          final Vendors vendors = snap.data[1] as Vendors;
            if (deals.getAllGoldDeals().length > 0){
              return Stack(
                children: <Widget>[
                  getDealsWidget(deals, state),
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
                            settings: RouteSettings(name: "MapPage"),
                            builder: (BuildContext context) {
                              return new MapPageWidget(vendors.getVendorList(), state.location);
                            },
                            fullscreenDialog: true
                          )
                        );
                      },
                    )
                  ),
                ],
              );
            } else if (deals.isLoading){
              //Geofire not ready, show loading
              return Loading(text: "Loading Deals...");
            }
            //If geofire has loaded but we got no deals, tell user no deals
            return TextPage(text: "No deals nearby.");
        }
      );
    } else {
      //did not match a state
      return TextPage(text: "An error occured.");
    }
  }

Widget _buildCarousel(BuildContext context, int carouselIndex, List<Deal> carouselDeals, String carouselText, DealsState state) {
  var viewportFrac = 0.7;
  if(MediaQuery.of(context).size.shortestSide > 600){//this is getting into tablet range
    viewportFrac = 0.35; //make a couple fit on the page
  }
  var cardSize = viewportFrac * MediaQuery.of(context).size.width;
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
        child: (carouselDeals.length <= 0)? Container():ListView.builder(
          key: PageStorageKey('dealGroup$carouselIndex'), //save deal group's position when scrolling
          scrollDirection: Axis.horizontal,
          physics: SavourCarouselScrollPhysics(itemDimension: cardSize),
          itemBuilder: (BuildContext context, int item) {
            return GestureDetector(
              onTap: () {
                print(carouselDeals[item].key + " clicked");
                Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                    settings: RouteSettings(name: "DealPage"),
                    builder: (context) => BlocProvider<RedemptionBloc>(
                      create: (context) => RedemptionBloc(),
                      child: DealPageWidget(
                        dealId: carouselDeals[item].key, 
                        location: state.location,
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: cardSize,
                child: DealCard(
                  deal: carouselDeals[item], 
                  location: state.location, 
                  type: DealCardType.medium,
                ),
              ),
            );
          },
          itemCount: carouselDeals.length,  
        ),
      )
    ],
  );
}

  Widget getDealsWidget(Deals deals, DealsState state){
    if (deals!= null && deals.count > 0){
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics (),
        padding: EdgeInsets.only(top: 10.0),
        itemBuilder: (context, position) {
          List<Deal> filterDeals = [];
          var filterText = "";
          switch (position) {
            case 0:
              filterDeals = deals.getGoldDealsByFilter(0);
              filterText = deals.filters[0] + " Deals";
              break;
            case 1: 
              filterDeals = deals.getGoldDealsByValue();
              filterText = "Deals By Value";
              break;
            case 2:
              filterDeals = deals.getGoldDealsByDistance();
              filterText = "Deals By Distance";
              break;
            default:
              filterDeals = deals.getGoldDealsByFilter(position-2);
              filterText = deals.filters[position-2] + " Deals";
          }
          return (filterDeals.length > 0)? _buildCarousel(context, position, filterDeals, filterText, state): Container();
        },
        itemCount: deals.filters.length+2,
      );
    }
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
  }
}