library savour.globals; 

import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:savour_deals_flutter/repositories/deals/deals_provider.dart';
import 'package:savour_deals_flutter/repositories/deals/deals_repo.dart';
import 'package:savour_deals_flutter/repositories/redemptions/redemptions_provider.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_provider.dart';
import 'package:savour_deals_flutter/repositories/vendors/vendors_repo.dart';

class Utils {
    static final Random _random = Random.secure();

    static String createCryptoRandomString([int length = 32]) {
        var values = List<int>.generate(length, (i) => _random.nextInt(256));

        return base64Url.encode(values);
    }
}

class ColorWithFakeLuminance extends Color {
  //This class is used to spoof app bar color on ios so that we always have white status bar text
  final bool withLightLuminance;

  ColorWithFakeLuminance (Color color, {@required this.withLightLuminance})
  :super(color.value);

  double get luminance{
    return withLightLuminance ? 0 : 1;
  }

  double computeLuminance() => luminance;
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left + 
    _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
    _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth -
    _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight -
    _safeAreaVertical) / 100;
  }
}

final DealsApiProvider dealsApiProvider = DealsApiProvider();  
final VendorsApiProvider vendorApiProvider = VendorsApiProvider(); 
final RedemptionsApiProvider redemptionApiProvider = RedemptionsApiProvider(); 
final DealRepository dealRepository = DealRepository();
final VendorRepository vendorRepository = VendorRepository();

final Random random = new Random();
