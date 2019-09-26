
import 'dart:ffi';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/containers/likeButtonWidget.dart';
import 'package:savour_deals_flutter/icons/savour_icons_icons.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

enum DealCardType {  
  small,
  medium,
  large, 
}

final double largeScalar = 1.0;
final double mediumScalar = 0.8;

class DealCard extends StatelessWidget {
  final Deal deal;
  final Position location;
  final DealCardType type;
  final Function(String, bool) onFavoriteChanged;
  final double whSize;


  const DealCard({
    Key key, 
    @required this.deal, 
    @required this.location, 
    @required this.type, 
    this.onFavoriteChanged = _dummyFunction, 
    this.whSize,
  }) : super(key: key);

  static void _dummyFunction(String dummyID, bool dummyFavorite) {}

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case DealCardType.large:
        return DealCardFull(
          deal: deal,
          location: location,
          scalar: largeScalar,
          onFavoriteChanged: onFavoriteChanged,
        );
      case DealCardType.medium:
        return DealCardFull(
          deal: deal,
          location: location,
          scalar: mediumScalar,
          onFavoriteChanged: onFavoriteChanged,
        );
      case DealCardType.small:
        return DealCardSmall(
          deal: deal,
          onFavoriteChanged: onFavoriteChanged,
          whSize: whSize,
        );
      default:
        //should not get here
        return Container();
    }

  }
}

class DealCardFull extends StatelessWidget {
  final double scalar;
  final Deal deal;
  final Position location;
  final Function(String, bool) onFavoriteChanged;

  const DealCardFull({Key key, @required this.scalar, @required this.deal, @required this.location, this.onFavoriteChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0*scalar),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0*scalar),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0*scalar), topRight: Radius.circular(15.0)*scalar),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 200*scalar,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AdvancedNetworkImage(
                      deal.photo,
                      useDiskCache: true,
                      cacheRule: CacheRule(maxAge: const Duration(days: 1)),
                      scale: 0.2,
                      printError: true,
                    ),
                    fit: BoxFit.cover,
                    // loadingWidget: Container(
                    //   color: Colors.transparent,
                    //   child: const Icon(Icons.local_dining, 
                    //     color: Colors.white,
                    //     size: 150.0,
                    //   ),
                    // ),   
                    // forceRebuildWidget: true,                 
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                ),
                CountdownWidget(
                  deal: deal,
                  scalar: scalar,
                ),
                Container(
                  height: 200*scalar,
                  child: Align(
                    alignment: Alignment(-.95,.9),
                    child: deal.isPreferred()? Icon(Icons.star, color: Colors.white): null,
                  ),
                ),
              ]
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
            child: Container(
              width: MediaQuery.of(context).size.width*.85,
              child: new AutoSizeText(
                deal.description,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                minFontSize: 5.0,
                maxFontSize: 18.0,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
            child: Text(deal.vendor.name + " - " + deal.vendor.distanceMilesFrom(location.latitude, location.longitude).toStringAsFixed(1), 
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(height: 5.0,),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 7.0),
                child: ActiveDaysWidget(
                  deal: deal,
                ),
              ),
              Expanded(
                child: Container(
                ),
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: LikeButton(
                  deal: deal,
                  onFavoriteChanged: onFavoriteChanged,
                )
              )
            ],
          ),
        ],
      ),
    );
  }
}

class DealCardSmall extends StatelessWidget {
  final Deal deal;
  final Function(String, bool) onFavoriteChanged;
  final double whSize;

  const DealCardSmall({Key key, @required this.deal, this.onFavoriteChanged, this.whSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: whSize,
      height: whSize,
      child: Card(
        // margin: EdgeInsets.all(10.0),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: <Widget>[
              Container(
                height: whSize,
                width: whSize,
                child: Image(
                  image: AdvancedNetworkImage(
                    deal.photo,
                    useDiskCache: true,
                    cacheRule: CacheRule(maxAge: const Duration(days: 1)),
                    printError: true,
                  ),
                  fit: BoxFit.cover,               
                ),
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
              ),
              Container(
                width: whSize,
                height: whSize,
                color: Colors.black.withOpacity(0.5),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: whSize,
                      child: new AutoSizeText(
                        deal.description,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        minFontSize: 10.0,
                        maxFontSize: 22.0,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 5.0,
                left: 10.0,
                right: 10.0,
                child: CountdownWidget(
                  deal: deal,
                  scalar: 1.0,
                ),
              ),
            ]
          ),
        ),
      ),
    );
    //Add favorite button after rework of handling data
  }
}

class ActiveDaysWidget extends StatelessWidget {
  final Deal deal;

  const ActiveDaysWidget({Key key, @required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> days= [" Mo.", " Tu.", " We.", " Th.", " Fr.", " Sa.", " Su."];
    var daysIdxs = [6,0,1,2,3,4,5];
    List<Widget> list = List<Widget>();
    for(var day in daysIdxs){
      list.add(
        Container(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 1.0, 10.0),
          alignment: Alignment.topCenter,
          transform: Matrix4.translationValues(-0.0, -10.0, 0.0),
          child: Column(
            children: <Widget>[
              Text(
                days[day], 
                textAlign: TextAlign.left,
                style: TextStyle(
                  //Color it red when deal is not active
                  color: deal.isActive()? SavourColorsMaterial.savourGreen: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              Container(height: 5.0,),
              deal.activeDays[day] ? 
              Icon(SavourIcons.circle,
              //Color it red when deal is not active
                color: deal.isActive()? SavourColorsMaterial.savourGreen: Colors.red, 
                size: 12.0,
              ):
              Icon(SavourIcons.circle_thin,
                color: deal.isActive()? SavourColorsMaterial.savourGreen: Colors.red,
                size: 12.0,
              ),
            ],
          )
          
          
        ),
      );
    }
    return Row(
      children: list
    );
  }
}

class CountdownWidget extends StatelessWidget {
  final double scalar;
  final Deal deal;

  const CountdownWidget({Key key, @required this.scalar, @required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var info = deal.infoString();
    if(deal.redeemed){
      return Container(
        height: 200*scalar,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Text("Deal already redeemed!", style: TextStyle(color: Colors.white),),
            color: Colors.black54,
          ),
        ),
      );
    }else if(deal.countdownString() != ""){
      return Container(
        height: 200*scalar,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Text(deal.countdownString(), style: TextStyle(color: Colors.white),),
            color: Colors.black54,
          ),
        ),
      );
    }else if (info != "" || info.contains("available")){
      return Container(
        // height: 200*scalar,
        width: MediaQuery.of(context).size.width,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Text(info, style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
            color: Colors.black54,
          ),
        ),
      );
    }
    return Container();
  }
}