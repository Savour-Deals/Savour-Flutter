
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/blocs/redemption/redemption_bloc.dart';
import 'package:savour_deals_flutter/blocs/wallet/wallet_bloc.dart';
import 'package:savour_deals_flutter/containers/custom_title.dart';
import 'package:savour_deals_flutter/containers/dealCardWidget.dart';
import 'package:savour_deals_flutter/containers/loading.dart';
import 'package:savour_deals_flutter/containers/textPage.dart';
import 'package:savour_deals_flutter/pages/infoPages/vendorPage.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/stores/deals_model.dart';
import 'package:savour_deals_flutter/stores/redemption_model.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/utils.dart' as globals;
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:savour_deals_flutter/pages/infoPages/dealPage.dart';

import 'accountModalPage.dart';

class WalletPageWidget extends StatefulWidget {

  WalletPageWidget();

  @override
  _WalletPageWidgetState createState() => _WalletPageWidgetState();
}

class _WalletPageWidgetState extends State<WalletPageWidget> with SingleTickerProviderStateMixin{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Location variables
  Position currentLocation;

  WalletBloc _walletBloc;

  int tabIndex = 0;
  TabController _tabController;

  //Declare contextual variables
  AppState appState;
  ThemeData theme;

  List<Widget> tabs = [Container(),Container()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    _walletBloc = BlocProvider.of<WalletBloc>(context);
    initPlatform();
  }

  void initPlatform() async {
    try {
      var serviceStatus = await  checkPermission();
      print("Service status: $serviceStatus");
      if (serviceStatus == LocationPermission.always || serviceStatus == LocationPermission.whileInUse) {
        currentLocation = await getLastKnownPosition();
      }
    } on PlatformException catch (e) {
      print(e);
    }

    if(currentLocation != null){
      _walletBloc.add(FetchData(location: currentLocation));
    }

    getPositionStream().listen((Position result) async {
      _walletBloc.add(UpdateWalletLocation(location: currentLocation));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: SavourTitle(),
        centerTitle: true,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          FlatButton(
            child: Text("Logout", style: TextStyle(color: Colors.red) ),
            color: Colors.transparent,
            onPressed: (){
              FirebaseDatabase.instance.goOffline(); //If logged out, disable db connection
              Navigator.pop(context);
              _auth.signOut();
            },
          )
        ],
        bottom: Platform.isAndroid? 
        TabBar(
          labelStyle: TextStyle(fontSize: 25),
          controller: _tabController,
          tabs: <Widget>[
            Text("Favorites"),
            Text("Account"),
          ],
          onTap: (value) {
            setState(() {
              tabIndex = value;
            });
          },
        ):
        PreferredSize(
          preferredSize: Size(double.infinity, 45.0),
            child: Padding(
              padding: EdgeInsets.only(top: 5.0,bottom: 10.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 15.0,
                  ),
                  Expanded(
                    child: CupertinoSlidingSegmentedControl(
                      thumbColor: Colors.white.withOpacity(0.5),
                      backgroundColor: Colors.white.withOpacity(0.3),
                      groupValue: tabIndex,
                      onValueChanged: (value){
                        setState(() {
                          tabIndex = value;
                        });
                      },
                      children: <int, Widget>{
                        0: Text("Favorites"),
                        1: Text("Account"),
                      },
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),                
                ],
              ),
            ),
          ), 
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletUninitialized || state is WalletLoading) {
            return Loading(text: "Loading Vendors...");
          } else if (state is WalletError) {
            return TextPage(text: "An error occured.");
          } else if (state is WalletLoaded) {
            if (tabIndex == 0){
              return FavoritesPageWidget(location: state.location);
            } else if (tabIndex == 1){
              return AccountPageWidget();
            }
            return TextPage(text: "An error occured."); //should not happen
          }
          return TextPage(text: "Invalid State.");
        }
      )
    );
  }
}

class FavoritesPageWidget extends StatefulWidget {
  final Position location;

  const FavoritesPageWidget({Key key, @required this.location}) : super(key: key);

  @override
  _FavoritesPageWidgetState createState() => _FavoritesPageWidgetState();
}

class _FavoritesPageWidgetState extends State<FavoritesPageWidget> {

  int totalSavings = 0;

  @override
  void initState() {
    super.initState();
    FirebaseDatabase().reference().child("Users").child(FirebaseAuth.instance.currentUser.uid).child("total_savings").onValue.listen((datasnapshot) {
      if (this.mounted){
        setState(() {
          totalSavings = datasnapshot.snapshot.value ?? 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext _) {
    return StreamBuilder<Deals>(
      stream: globals.dealsApiProvider.dealsStream,
      initialData: globals.dealsApiProvider.deals,
      builder: (BuildContext context, AsyncSnapshot<Deals> snap) {
        final favorites = snap.data.getFavorites();
        if (favorites.length > 0){
          return ListView.builder(
            padding: EdgeInsets.only(top: 10.0),
            physics: const AlwaysScrollableScrollPhysics (),
            itemBuilder: (context, position) {
              if(position == 0){
                return Text(
                  "Total Estimated Savings: \$" + totalSavings.toString(), 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                );
              }
              return GestureDetector(
                onTap: () {
                  print(favorites[position-1].key + " clicked");
                  Navigator.push(
                    context,
                    platformPageRoute(
                      context: context,
                      settings: RouteSettings(name: "DealPage"),
                      builder: (BuildContext context) {
                        return BlocProvider<RedemptionBloc>(
                          create: (context) => RedemptionBloc(),
                          child: DealPageWidget(
                            dealId: favorites[position-1].key, 
                            location: widget.location
                          ),
                        );
                      },
                    ),
                  );
                },
                child: getCard(favorites[position-1])
              );
            },
            itemCount: favorites.length+1,
          );
        }
        return ListView(
          padding: EdgeInsets.only(top: 10.0),
          children: <Widget>[
            Text(
              "Total Estimated Savings: \$" + totalSavings.toString(), 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Container(height: 20,),
            Center(child: Text("No favorites to show!"))
          ],
        );
      }
    );
  }

  Widget getCard(Deal deal){
    return DealCard(
      deal: deal, 
      location: widget.location, 
      type: DealCardType.large,
    );
  }
}

class RedeemedWidget extends StatefulWidget {
  final Position location;

  RedeemedWidget({Key key, @required this.location});

  _RedeemedWidgetState createState() => _RedeemedWidgetState();
}

class _RedeemedWidgetState extends State<RedeemedWidget> {
  //database variables 
  User user;
  int totalSavings = 0;

  //Declare contextual variables
  ThemeData theme;


  @override
  void initState() {
    super.initState();
    FirebaseDatabase().reference().child("Users").child(FirebaseAuth.instance.currentUser.uid).child("total_savings").onValue.listen((datasnapshot) {
      if (this.mounted){
        setState(() {
          totalSavings = datasnapshot.snapshot.value ?? 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        return StreamBuilder<List<Redemption>>(
          stream: globals.redemptionApiProvider.redemptionsStream,
          initialData: globals.redemptionApiProvider.redemptions,
          builder: (BuildContext context, AsyncSnapshot<List<Redemption>> snap) {
            final redemptions = snap.data;
            if (redemptions.length > 0){
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics (),
                padding: EdgeInsets.only(top: 10.0),
                itemBuilder: (context, position) {
                  if(position == 0){
                    return Text(
                      "Total Estimated Savings: \$" + totalSavings.toString(), 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    );
                  }
                  return Container(
                    height: 100,
                    child: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                      leading: CircleAvatar(
                        backgroundColor: theme.primaryColor,
                        backgroundImage: AdvancedNetworkImage(
                          (redemptions[position-1].redemptionType == RedemptionType.deal)? redemptions[position-1].deal.photo : redemptions[position-1].vendor.photo,
                          retryDuration: Duration(milliseconds: 1),
                          fallbackAssetImage: 'images/glass-and-fork.png',
                        ),
                      ),
                      title: Text(
                        redemptions[position-1].redemptionType == RedemptionType.loyaltyRedeem?
                          "You redeemed a loyalty reward at " + redemptions[position-1].vendor.name: 
                            redemptions[position-1].redemptionType == RedemptionType.loyaltyCheckin? 
                              "You checked in at " + redemptions[position-1].vendor.name:
                              "You redeemed a deal from " + redemptions[position-1].deal.vendorName 
                      ),
                      trailing: Text(timeago.format(DateTime.fromMillisecondsSinceEpoch(-1*redemptions[position-1].timestamp*1000), allowFromNow: true)),
                      onTap: (){
                        if(redemptions[position-1].redemptionType == RedemptionType.deal){
                          Navigator.push(context,
                            platformPageRoute(
                              context: context,
                              settings: RouteSettings(name: "DealPage"),
                              builder: (BuildContext context) {
                                return BlocProvider<RedemptionBloc>(
                                  create: (context) => RedemptionBloc(),
                                  child: DealPageWidget(
                                    dealId: redemptions[position-1].deal.key, 
                                    location: widget.location
                                  ),
                                );
                              },
                            )
                          );
                        }else{
                          Navigator.push(context,
                            platformPageRoute(
                              context: context,
                              settings: RouteSettings(name: "DealPage"),
                              builder: (BuildContext context) {
                                return VendorPageWidget(redemptions[position-1].vendor, widget.location);
                              },
                            )
                          );
                        }
                      },
                    ),
                  );
                },
                itemCount: redemptions.length+1,
              );
            }
            return ListView(
              padding: EdgeInsets.only(top: 10.0),
              children: <Widget>[
                Text(
                  "Total Estimated Savings: \$" + totalSavings.toString(), 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Container(height: 20,),
                Center(
                  child: globals.redemptionApiProvider.isLoaded? 
                  Text("No Redemptions.\nRedeem deals to start saving!", textAlign: TextAlign.center,) : 
                  PlatformCircularProgressIndicator())
              ],
            );
          }
        );
      }
    );
  }
}