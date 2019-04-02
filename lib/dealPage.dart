import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/vendorPage.dart';

class DealPageWidget extends StatelessWidget {
  final String text;

  DealPageWidget(this.text);

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
          child: Text("To Vendor",
            style: whiteText,
          ), 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VendorPageWidget("Vendor Page")),
            );
          },
        )
      ),
    );
  }
}