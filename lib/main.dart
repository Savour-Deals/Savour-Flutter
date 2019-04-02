import 'dart:io';

import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/login/login.dart';
import 'package:savour_deals_flutter/tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async { 
  runApp(SavourApp()); }

class SavourApp extends StatefulWidget {
  @override
  _SavourDealsState createState() => new _SavourDealsState();
}

class _SavourDealsState extends State<SavourApp> {
  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
  }
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savour Deals',
      theme: savourMaterialThemeData,
      debugShowCheckedModeBanner: false,
      home: _handleCurrentScreen(),
    );
  }

  Widget _handleCurrentScreen() {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return new LoginPage();
        } else {
          //check if user data present
          if (snapshot.hasData) {
            var user = snapshot.data;
            //Either their email is verified or they logged in with fb
            if (verifyUser(user)){
              return new SavourTabPage(uid: snapshot.data.uid);
            }
          }
          return new LoginPage();
        }
      }
    );
  }

  verifyUser(user){
    if (user.isEmailVerified){
      //user email is verified
      return true;
    }else if(user.providerData[0].providerId == "facebook.com"){
      //user logged in w/ FB
      return true;
    }
    return false;
  }
}



