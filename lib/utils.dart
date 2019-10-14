import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';

class Utils {
    static final Random _random = Random.secure();

    static String createCryptoRandomString([int length = 32]) {
        var values = List<int>.generate(length, (i) => _random.nextInt(256));

        return base64Url.encode(values);
    }
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