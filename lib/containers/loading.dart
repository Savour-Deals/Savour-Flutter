import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class Loading extends StatelessWidget {
  final String text;
  const Loading({this.text}) : super();

  @override
  Widget build(BuildContext context) {
    return Center (
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              PlatformCircularProgressIndicator(),
              Container(height: 10),
              AutoSizeText(
                text,
                maxFontSize: 22,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width*0.5,
          height: MediaQuery.of(context).size.width*0.4,
        ),
      )
    );
  }
}