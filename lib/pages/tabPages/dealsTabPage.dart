part of tab_lib;

class DealsPageWidget extends StatefulWidget {
  DealsPageWidget();

  @override
  _DealsPageState createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPageWidget> {
  //Location variables
  final _locationService = Geolocator();
  Position currentLocation;
  // Position currentLocation;

  //Declare contextual variables
  AppState appState;
  NotificationData notificationData;
  ThemeData theme;

  FirebaseUser user;

  SharedPreferences prefs;
  BuildContext showcasecontext;
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();

  DealBloc _dealsBloc;

  @override
  void initState() {
    super.initState();
    _dealsBloc = BlocProvider.of<DealBloc>(context);
    initPlatform();
  }

  void presentShowcase(){
    if (showcasecontext != null){
      ShowCaseWidget.of(showcasecontext).startShowCase([_one, _two, _three]);
    }
  }

  void initPlatform() async {
    //Intializing geoFire
    // geo.initialize("Vendors_Location");
    user = await FirebaseAuth.instance.currentUser();
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
      _dealsBloc.add(FetchDeals(location: currentLocation));
    }

    //Do we need to show help for new app flow?
    prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('hasOnboarded')){
      prefs.setBool('hasOnboarded', true);
      presentShowcase();
    }

    _locationService.getPositionStream(LocationOptions(accuracy: LocationAccuracy.medium, distanceFilter: 400)).listen((Position result) async {
      currentLocation = result;
      if (currentLocation == null){
        _dealsBloc.add(FetchDeals(location: currentLocation));
      }else{
        _dealsBloc.add(UpdateDealsLocation(location: currentLocation));
      }
    });//.cancel();
  }

  void displayNotiDeal() async {
    if (notificationData.isNotiDealPresent){
      print("DealID: ${notificationData.consumeNotiDealID}");
      Navigator.push(
        context,
        platformPageRoute(
          context: context,
          settings: RouteSettings(name: "DealPage"),
          builder: (context) => DealPageWidget(
            dealId: notificationData.consumeNotiDealID,
            location: currentLocation,
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
    return BlocBuilder<DealBloc, DealState>(
      builder: (context, state) {
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) {
              showcasecontext = context;
              return PlatformScaffold(
                appBar: PlatformAppBar(
                  leading: Showcase(
                    key: _one,
                    title: 'Search',
                    description: 'Search for deals and restaurants!',
                    shapeBorder: CircleBorder(),
                    showArrow: false,
                    child: FlatButton(
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
                  ),
                  title: Image.asset("images/Savour_White.png"),
                  trailingActions: <Widget>[
                    Showcase(
                      key: _two,
                      title: 'My Wallet',
                      description: 'View your favorite deals and past redemptions!',
                      shapeBorder: CircleBorder(),
                      showArrow: false,
                      child: FlatButton(
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
                    ),
                  ],
                  ios: (_) => CupertinoNavigationBarData(
                    backgroundColor: ColorWithFakeLuminance(theme.appBarTheme.color, withLightLuminance: true),
                    heroTag: "dealTab",
                    transitionBetweenRoutes: false,
                  ),
                ),
                body: Material(child: bodyWidget(state)),
              );
            },
          )
        );
      }
    );
  }

  Widget _searchPage(DealState state){
    if (state is DealLoaded) {
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
  
  Widget bodyWidget(DealState state){
    if (state is DealUninitialized) {
      return Loading(text: "Loading Deals...");
    } else if (state is DealError) {
      return TextPage(text: "An error occured.");
    } else if (state is DealLoaded) {
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
            if (deals.getAllDeals().length > 0){
              return Stack(
                children: <Widget>[
                  getDealsWidget(deals, state),
                  Align(
                    alignment: Alignment(-0.90, 0.90),
                    child: Showcase(
                      key: _three,
                      title: 'Maps',
                      description: "See what's nearby!",
                      shapeBorder: CircleBorder(),
                      showArrow: false,
                      child:  FloatingActionButton(
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
                      ),
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

Widget _buildCarousel(BuildContext context, int carouselIndex, List<Deal> carouselDeals, String carouselText, DealState state) {
  var viewportFrac = 0.7;
  var initialPage = 0;
  if(MediaQuery.of(context).size.shortestSide > 600){//this is getting into tablet range
    viewportFrac = 0.35; //make a couple fit on the page
    initialPage = 1;
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

  Widget getDealsWidget(Deals deals, DealState state){
    if (deals!= null && deals.count > 0){
      return ListView.builder(
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