import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/pages/loginPages/resetAccountPage.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/themes/decoration.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

import 'createAccountPage.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {



  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool _passwordObscured = true;
  DatabaseReference userRef;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return PlatformScaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/login_background.jpg"),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.45), BlendMode.srcATop
            ),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(18.0),
            child: SingleChildScrollView(
                child: Column(
                children: <Widget>[
                  Image(image: AssetImage("images/Savour_Deals_White.png")),
                  LoginTextInput(
                    hint: "Email", 
                    controller: emailController,
                    keyboard: TextInputType.emailAddress
                  ),
                  Container(padding: EdgeInsets.all(5)),
                  LoginTextInput(
                    hint: "Password",
                    controller: passwordController,
                    keyboard: TextInputType.text,
                    obscureTxt: _passwordObscured,
                    suffixIcon: IconButton(
                      color: Colors.black,
                      icon: Icon(
                        _passwordObscured
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordObscured = !_passwordObscured;
                        });
                      },
                    ),
                  ),
                  Container(padding: EdgeInsets.all(5)),
                  PlatformButton(
                    ios: (_) => CupertinoButtonData(
                      pressedOpacity: 0.7,
                    ),
                    android: (_) => MaterialRaisedButtonData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    color: SavourColorsMaterial.savourGreen,
                    child: Text("Login", style: whiteText),
                    onPressed: () {
                      login();
                    },
                  ),
                  Container(padding: EdgeInsets.all(5)),
                  PlatformButton(
                    ios: (_) => CupertinoButtonData(
                      pressedOpacity: 0.7,
                    ),
                    android: (_) => MaterialRaisedButtonData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    color: Colors.blueAccent,
                    child: Text("Facebook Login", style: whiteText),
                    onPressed: () {
                      facebookLogin();
                    },
                  ),
                  Container(padding: EdgeInsets.all(5),alignment: Alignment.bottomCenter,),
                  GestureDetector(
                    onTap: () async {
                      print("create account pressed");
                      await Navigator.push(context, platformPageRoute(maintainState: false,
                            builder: (BuildContext context) {
                        return new CreateAccountPage(_auth);
                      },
                          fullscreenDialog: true
                      ),
                      );
                      _displayCreateAccountSuccess();
                    },
                    child: Text("Create Account", style: TextStyle(color: Colors.white),),
                  ),
                  Container(padding: EdgeInsets.all(5),alignment: Alignment.bottomCenter,),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context, platformPageRoute(maintainState: false,
                          builder: (BuildContext context) {
                            return new ResetAccountPage(_auth);
                          },
                          fullscreenDialog: true
                      ),
                      );
                      _displayResetAccountSuccess();
                    },
                    child: Text("Reset Account", style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _displayCreateAccountSuccess() async {
    var currentUser = await _auth.currentUser();
    print("CURRENT USER");
    print(currentUser.email);
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return PlatformAlertDialog(
          title: new Text("Account Created!"),
          content: new Text("Please check your email to authenticate your account"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _displayResetAccountSuccess() async {
    var currentUser = await _auth.currentUser();
    print("CURRENT USER");
    print(currentUser.email);
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return PlatformAlertDialog(
          title: new Text("Account Reset!"),
          content: new Text("Please check your email to reset your password"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void login() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty){
      displayError("Missing email or password","Please provide both an email and password", "OK");
    } else {
        _auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text).catchError((error){
          displayError("Login Failed!","Please check that your email and password are correct and try again.", "OK");
        }).then((user){
          if (!user.isEmailVerified){
            promptUnverified(user: user);
          }
        });
    }
  }

  void facebookLogin() async {
    var facebook = new FacebookLogin();
    facebook.loginBehavior = FacebookLoginBehavior.webViewOnly;

    var result = await facebook.logInWithReadPermissions(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        _auth.signInWithCredential(FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token)
        ).then((fbauth) async {
          UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
          userRef = FirebaseDatabase.instance.reference().child("Users").child(fbauth.uid);

          var graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${result.accessToken.token}');

          var profile = json.decode(graphResponse.body);
          if (profile['name'] != null){
            userUpdateInfo.displayName = profile['name'];
            userRef.child("full_name").set(profile['name']);
          }
          if (profile['id'] != null){
            userUpdateInfo.photoUrl = "https://graph.facebook.com/" + profile['id'] + "/picture?height=500";
            userRef.child("photo").set("https://graph.facebook.com/" + profile['id'] + "/picture?height=500");
            userRef.child("facebook_id").set(profile['id']);
          }
          if (profile['email'] != null){
            userRef.child("email").set(profile['email']);
          }
          fbauth.updateProfile(userUpdateInfo);
        });
        
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        displayError("Facebook Error", "Please try again.", "OK");
        break;
    }
  }

  void displayError(title, message, buttonText){
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return PlatformAlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(buttonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void promptUnverified({user: FirebaseUser}){
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return PlatformAlertDialog(
          title: new Text("Unverified Email"),
          content: new Text("Check your email for a verification link. Then come back and try again."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Resend Email"),
              onPressed: () {
                user.sendEmailVerification();
              },
            ),
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
