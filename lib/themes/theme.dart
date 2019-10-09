import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final ThemeData savourMaterialLightThemeData = new ThemeData(
  brightness: Brightness.light,
  primaryColor: SavourColorsMaterial.savourGreen,
  primaryColorBrightness: Brightness.light,
  accentColor: Colors.white,//Colors.black,
  accentColorBrightness: Brightness.light,
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  splashFactory: NoSplashFactory(),
  cardTheme: CardTheme(color: Colors.white),
  dialogTheme: DialogTheme(backgroundColor: Colors.white),
);

final ThemeData savourMaterialDarkThemeData = new ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.white,
  accentColorBrightness: Brightness.dark,
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  backgroundColor: Colors.black,
  splashFactory: NoSplashFactory(),
  dialogBackgroundColor: Color(0xff4C4C4C),
  cardTheme: CardTheme(color: Color(0xff4C4C4C)),
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


class NoSplashFactory extends InteractiveInkFeatureFactory {
  const NoSplashFactory();
  
  @override
  InteractiveInkFeature create({MaterialInkController controller, RenderBox referenceBox, Offset position, Color color, TextDirection textDirection, bool containedInkWell = false, rectCallback, BorderRadius borderRadius, ShapeBorder customBorder, double radius, onRemoved}) {
    return new NoSplash(
      controller: controller,
      referenceBox: referenceBox,
    );
  }

}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    VoidCallback onRemoved,
  })  : assert(controller != null),
        assert(referenceBox != null),
        super(controller: controller,referenceBox: referenceBox,onRemoved: onRemoved){
          controller.addInkFeature(this);//Added per https://github.com/flutter/flutter/issues/20874
        }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}


