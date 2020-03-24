import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class  LoginTextInput extends StatefulWidget {
  LoginTextInput({this.hint, this.controller, this.keyboard, this.suffixIcon, this.obscureTxt, this.prefix });

  final String hint;
  final TextEditingController controller;
  final TextInputType keyboard;
  final IconButton suffixIcon;
  final bool obscureTxt;
  final Widget prefix;

  @override
  _LoginTextInputState createState() => _LoginTextInputState();
}

class _LoginTextInputState extends State<LoginTextInput> {
  bool obscured;

  @override
  void initState() {
    super.initState();
    if (widget.obscureTxt != null){
      obscured = widget.obscureTxt;
    }else{
      obscured = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboard,
      decoration: InputDecoration(
        prefix: widget.prefix,
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.grey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
        labelStyle: TextStyle(color: Colors.white),
        suffixIcon: widget.suffixIcon,
      ),
      obscureText: obscured,
      cursorColor: Colors.white
    );  
  }
}