import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/pages/vendorPage.dart';

class DealPageWidget extends StatelessWidget {
  final Deal deal;

  DealPageWidget(this.deal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deal Page",
          style: whiteTitle,
        ),
      ),
      body: Center(
        child: FlatButton(
          color: SavourColorsMaterial.savourGreen,
          child: Text("See More from " + deal.vendor.name,
            style: whiteText,
          ), 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VendorPageWidget(deal.vendor)),
            );
          },
        )
      ),
    );
  }
}