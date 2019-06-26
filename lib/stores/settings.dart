import 'package:flutter/widgets.dart';

import '../main.dart';

class InheritedStateWidget extends StatefulWidget {
  @override
  InheritedStateWidgetState createState() => InheritedStateWidgetState();
}

class InheritedStateWidgetState extends State<InheritedStateWidget> {
  bool _isDark = true;

  bool get isDark => _isDark;

  void setDarkMode(bool newVal) {
    setState(() {
      _isDark = newVal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MyInheritedWidget(
      data: this,
      child: SavourApp(),
    );
  }
}

class MyInheritedWidget extends InheritedWidget {
  final InheritedStateWidgetState data;

  MyInheritedWidget({Key key, this.data, Widget child})
      : super(key: key, child: child);

  static MyInheritedWidget of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(MyInheritedWidget);

  @override
  bool updateShouldNotify(MyInheritedWidget old) => true;
}
