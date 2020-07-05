import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextPage extends StatelessWidget {
  final String text;
  const TextPage({this.text}) : super();

  @override
  Widget build(BuildContext context) {
    return Center (
      child: Text(text),
    );
  }
}