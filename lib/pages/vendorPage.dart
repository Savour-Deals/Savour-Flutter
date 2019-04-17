import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/stores/vendor_model.dart';
import 'package:savour_deals_flutter/themes/theme.dart';

class VendorPageWidget extends StatelessWidget {
  final Vendor vendor;

  VendorPageWidget(this.vendor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deal Page",
          style: whiteTitle,
        ),
        backgroundColor: SavourColorsMaterial.savourGreen,
      ),
      body: Column(
      ),
    );
  }
}