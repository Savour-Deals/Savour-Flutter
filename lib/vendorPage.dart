import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/themes/theme.dart';

class VendorPageWidget extends StatelessWidget {
  final String text;

  VendorPageWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vendor Page",
          style: whiteTitle,
        ),
      ),
      body: Column(
      ),
    );
  }
}