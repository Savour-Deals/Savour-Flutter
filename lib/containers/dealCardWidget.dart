import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';

class DealCard extends StatefulWidget {
  DealCard(this.deal, this.location);
  final Deal deal;
  Position location;

  @override
  _DealCardState createState() => _DealCardState();
}

class _DealCardState extends State<DealCard> {

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  height: 200.0,
                  child: Container(
                    child: Container(),
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: new NetworkImage(
                          widget.deal.photo,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ),
                inactiveWidget(),
                countdownWidget(),
              ]
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 5.0),
            child: Text(widget.deal.description, style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: Text("Su. Mo. Tu. We. Th. Fr. Sa.", style: TextStyle(color: SavourColorsMaterial.savourGreen)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
            child: Text(widget.deal.getActiveBubbles(), style: TextStyle(color: SavourColorsMaterial.savourGreen, fontSize: 35.0),),
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
        decoration: BoxDecoration(color: Colors.black38),
      ),
      widthFactor: 1.0,
    );
  }

  Widget countdownWidget(){
    if(widget.deal.countdownString() != ""){
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
