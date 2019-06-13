import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:savour_deals_flutter/containers/likeButtonWidget.dart';
import 'package:savour_deals_flutter/icons/savour_icons_icons.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';



class DealCard extends StatefulWidget {
  DealCard(this.deal, this.location);
  final Deal deal;
  final Position location;

  @override
  _DealCardState createState() => _DealCardState();
}

class _DealCardState extends State<DealCard> {

  @override
  Widget build(BuildContext context) {
    if (widget.deal.redeemed){
      var since = (DateTime.now().millisecondsSinceEpoch~/1000) - widget.deal.redeemedTime~/1000;
      if(since > 1800*3){
        return Container();//dont draw deal if it was redeemed 30min ago
      }
    }
    return Card(
      margin: EdgeInsets.all(10.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: TransitionToImage(
                    image: AdvancedNetworkImage(
                      widget.deal.photo,
                      useDiskCache: true,
                      cacheRule: CacheRule(maxAge: const Duration(days: 1)),
                    ),
                    fit: BoxFit.cover,
                    loadingWidget: Container(
                      color: Colors.transparent,
                      child: const Icon(Icons.local_dining, 
                        color: Colors.white,
                        size: 150.0,
                      ),
                    ),                    
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                ),
                inactiveWidget(),
                countdownWidget(),
              ]
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
            child: Text(widget.deal.description, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
            child: Text(widget.deal.vendor.name + " - " + widget.deal.vendor.distanceMilesFrom(widget.location.latitude, widget.location.longitude).toStringAsFixed(1)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
            child: getInfo(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
            child: daysWidget(),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 7.0),
                child: getActiveBubbles(),
              ),
              Expanded(
                child: Container(
                ),
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: LikeButton(widget.deal)
              )
            ],
          ),
          
        ],
      ),
    );
  }

  Widget inactiveWidget(){
    if (widget.deal.isActive()){
      return Container();
    }
    return FractionallySizedBox(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Text("Deal is currently inactive. It is "+ widget.deal.infoString()+".", 
          style: TextStyle(
            fontSize: 20.0, 
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        decoration: BoxDecoration(color: Colors.black45),
      ),
      widthFactor: 1.0,
    );
  }

  Widget daysWidget(){
    List<String> days= ["Su. ", "Mo. ", "Tu. ", "We. ", "Th. ", "Fr. ", "Sa. "];
    List<Widget> list = new List<Widget>();
    for(var day in days){
        list.add(Container(
          width: 25.0,
          height: 15.0,
          child: new AutoSizeText(
            day, 
            style: TextStyle(color: SavourColorsMaterial.savourGreen, fontSize: 150.0),
            minFontSize: 10,
            maxFontSize: 150.0,
            maxLines: 1,
          ),
        ),
      );
    }
    return new Row(children: list);
  }

  Widget getActiveBubbles(){
    var daysIdxs = [6,0,1,2,3,4,5];
    List<Widget> list = new List<Widget>();
    for(var day in daysIdxs){
      list.add(
        Container(
          width: 25.0,
          alignment: Alignment.topCenter,
          transform: Matrix4.translationValues(-0.0, -10.0, 0.0),
          child: widget.deal.activeDays[day] ? 
            Icon(SavourIcons.circle,
              color: SavourColorsMaterial.savourGreen,
              size: 10.0,
            ):
            Icon(SavourIcons.circle_thin,
              color:  SavourColorsMaterial.savourGreen,
              size: 10.0,
            ),
        ),
      );
    }
    return new Row(
      children: list
    );
  }

  Widget countdownWidget(){
    if(widget.deal.redeemed){
      return Container(
        height: 200,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Text("Deal already redeemed!", style: TextStyle(color: Colors.white),),
            color: Colors.black54,
          ),
        ),
      );
    }else if(widget.deal.countdownString() != ""){
      return Container(
        height: 200,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Text(widget.deal.countdownString(), style: TextStyle(color: Colors.white),),
            color: Colors.black54,
          ),
        ),
      );
    }
    return Container();
  }

  Widget getInfo(){
    var info = widget.deal.infoString();
    if (info == "" || info.contains("available")){
      return Container();
    }
    return Text(info, style: TextStyle(color: Colors.orange),textAlign: TextAlign.left,);
  }
}
