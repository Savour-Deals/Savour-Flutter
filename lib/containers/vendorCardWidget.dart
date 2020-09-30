import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:savour_deals_flutter/stores/settings.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/globals/themes/theme.dart';

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
    var appState = Provider.of<AppState>(context);
    return SizedBox(
      height: 225.0,
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image(
                image: AdvancedNetworkImage(
                  widget.vendor.photo,
                  useDiskCache: true,
                  cacheRule: CacheRule(maxAge: const Duration(days: 1)),
                ),
                fit: BoxFit.cover,
                // loadingWidget: Container(),  
                // placeholder: Container(),  
                // forceRebuildWidget: true,                
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            Container(
              color:(appState.isDark)? Colors.black.withOpacity(0.4):Colors.black.withOpacity(0.6),
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
            ),
            Align(
              alignment: Alignment(0.9, 0.8),
              child: widget.vendor.isPreferred? Icon(Icons.star, color: Color(0xFFD7B740)): null,
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
