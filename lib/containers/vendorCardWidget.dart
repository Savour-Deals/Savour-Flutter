import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';

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
              width: MediaQuery.of(context).size.width,
              child: TransitionToImage(
                image: AdvancedNetworkImage(
                  widget.vendor.photo,
                  useDiskCache: true,
                  cacheRule: CacheRule(maxAge: const Duration(days: 1)),
                ),
                fit: BoxFit.cover,
                loadingWidget: Container(),  
                placeholder: Container(),                  
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.6),
            ),
            Center(
              child: ListTile(
                title: Text(
                  widget.vendor.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                subtitle: Text(
                  widget.vendor.distanceMilesFrom(widget.location.latitude, widget.location.longitude).toStringAsFixed(1) + " Miles Away", 
                  style: whiteText,
                  textAlign: TextAlign.center,
                ),
              ),
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
