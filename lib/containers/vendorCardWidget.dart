import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';

class VendorCard extends StatefulWidget {
  VendorCard(this.vendor, this.location);
  final Vendor vendor;
  final Position location;

  @override
  _VendorCardState createState() => _VendorCardState();
}

class _VendorCardState extends State<VendorCard> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225.0,
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Stack(
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                color: Colors.black,
                image: new DecorationImage(
                  image: new NetworkImage(
                    widget.vendor.photo,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Column(
              children: <Widget>[
                Text(
                  widget.vendor.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.vendor.distanceMilesFrom(widget.location.latitude, widget.location.longitude).toStringAsFixed(1)
                ),
              ],
            )
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        margin: EdgeInsets.all(10),
      ),
    );
  }
}
