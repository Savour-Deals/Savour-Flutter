import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class  LoginTextInput extends StatefulWidget {
  LoginTextInput({this.hint, this.controller, this.keyboard, this.suffixIcon, this.obscureTxt });

  final String hint;
  final TextEditingController controller;
  final TextInputType keyboard;
  final IconButton suffixIcon;
  final bool obscureTxt;

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
    return PlatformTextField(
      controller: widget.controller,
      keyboardType: widget.keyboard,
      android: (_) => MaterialTextFieldData(
        decoration: InputDecoration(
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
      ),
      ios: (_) => CupertinoTextFieldData(
        placeholder: widget.hint,
        placeholderStyle: TextStyle(color: Colors.black),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        obscureText: obscured,
        cursorColor: Colors.white
      ),
    );  
  }
}