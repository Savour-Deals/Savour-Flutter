import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final CupertinoThemeData savourCupertinoThemeData = new CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: SavourColorsMaterial.savourGreen,
  // barBackgroundColor: SavourColorsMaterial.savourGreen,
);

final ThemeData savourMaterialThemeData = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: SavourColorsMaterial.savourGreen,
  primaryColor: SavourColorsMaterial.savourGreen,
  primaryColorBrightness: Brightness.dark,
  accentColor: SavourColorsMaterial.savourGreen,
  accentColorBrightness: Brightness.dark,
);
  

class SavourColorsMaterial {
  SavourColorsMaterial._(); // this basically makes it so you can instantiate this class
  static const _savourGreen = 0xFF49ABAA;
  static const MaterialColor savourGreen = MaterialColor (
    _savourGreen,
    const <int, Color>{
      50: const Color.fromRGBO(73, 171, 170, .1),
      100: const Color.fromRGBO(73, 171, 170, .2),
      200: const Color.fromRGBO(73, 171, 170, .3),
      300: const Color.fromRGBO(73, 171, 170, .4),
      400: const Color.fromRGBO(73, 171, 170, .5),
      500: const Color.fromRGBO(73, 171, 170, .6),
      600: const Color.fromRGBO(73, 171, 170, .7),
      700: const Color.fromRGBO(73, 171, 170, .8),
      800: const Color.fromRGBO(73, 171, 170, .9),
      900: const Color.fromRGBO(73, 171, 170, 1.0)
    },
  );
}

final TextStyle whiteTitle = new TextStyle(
  color: Colors.white,
);

final TextStyle whiteText = new TextStyle(
  color: Colors.white,
);



