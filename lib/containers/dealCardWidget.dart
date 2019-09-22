
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/utils.dart';
// import 'package:location/location.dart';
import 'package:savour_deals_flutter/containers/likeButtonWidget.dart';
import 'package:savour_deals_flutter/icons/savour_icons_icons.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
// import 'package:image/image.dart' as IMGTOOLS;




class DealCard extends StatefulWidget {
  DealCard(this.deal, this.location, this.largeDisplay);
  final Deal deal;
  final Position location;
  final bool largeDisplay;

  @override
  _DealCardState createState() => _DealCardState();
}

class _DealCardState extends State<DealCard> {
  double scalar;
  // Image image;


  @override
  void initState() {
    scalar = (widget.largeDisplay)? 1.0 : 0.8;
    super.initState();
  }

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
                      widget.deal.photo,
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
                countdownWidget(),
                Container(
                  height: 200*scalar,
                  child: Align(
                    alignment: Alignment(-.95,.9),
                    child: widget.deal.isPreferred()? Icon(Icons.star, color: Colors.white): null,
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
                widget.deal.description,
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
            child: Text(widget.deal.vendor.name + " - " + widget.deal.vendor.distanceMilesFrom(widget.location.latitude, widget.location.longitude).toStringAsFixed(1), 
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(height: 5.0,),
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

  // Widget daysWidget(){
  //   List<Widget> list = List<Widget>();
  //   for(var day in days){
  //     list.add(
  //       Container(
  //         // width: 25.0,
  //         height: 15.0,
  //         child: Text(
  //           day, 
  //           textAlign: TextAlign.left,
  //           style: TextStyle(
  //             //Color it red when deal is not active
  //             color: widget.deal.isActive()? SavourColorsMaterial.savourGreen: Colors.red,
  //             fontSize: 11,
  //             fontWeight: FontWeight.bold,
  //           ),
  //           // minFontSize: 10,
  //           // maxFontSize: 150.0,
  //           maxLines: 1,
  //         ),
  //       ),
  //     );
  //   }
  //   return Row(children: list);
  // }

  Widget getActiveBubbles(){
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
                  color: widget.deal.isActive()? SavourColorsMaterial.savourGreen: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              Container(height: 5.0,),
              widget.deal.activeDays[day] ? 
              Icon(SavourIcons.circle,
              //Color it red when deal is not active
                color: widget.deal.isActive()? SavourColorsMaterial.savourGreen: Colors.red, 
                size: 12.0,
              ):
              Icon(SavourIcons.circle_thin,
                color: widget.deal.isActive()? SavourColorsMaterial.savourGreen: Colors.red,
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

  Widget countdownWidget(){
    var info = widget.deal.infoString();
    if(widget.deal.redeemed){
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
    }else if(widget.deal.countdownString() != ""){
      return Container(
        height: 200*scalar,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Text(widget.deal.countdownString(), style: TextStyle(color: Colors.white),),
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
            child: Text(info, style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),//Text(widget.deal.countdownString(), style: TextStyle(color: Colors.white),),
            color: Colors.black54,
          ),
        ),
      );
    }
    return Container();
  }

  // Widget getInfo(){
  //   var info = widget.deal.infoString();
  //   // if (info == "" || info.contains("available")){
  //   //   return Container();
  //   // }
  //   return Text(info, style: TextStyle(color: Colors.orange),textAlign: TextAlign.left,);
  // }
}
