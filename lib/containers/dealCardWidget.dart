import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';

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
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
            child: SizedBox(
              height: 200.0,
              child: Container(
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
          ),
          ListTile(
            title: Text(widget.deal.description, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.deal.vendor.name + " - " + widget.deal.vendor.distanceMilesFrom(widget.location.latitude, widget.location.longitude).toStringAsFixed(1)),
          ),
          // Text()
        ],
      ),
    );
  }
}
