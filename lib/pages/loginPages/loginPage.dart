import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart'
  hide BuildContext;
import 'package:savour_deals_flutter/pages/loginPages/resetAccountPage.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/themes/decoration.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'createAccountPage.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {



  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  DatabaseReference userRef;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  BuildContext thisContext;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(
      screenName: 'LoginPage',
    );
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Stack(
      children: <Widget>[
        PlatformScaffold(
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
                      Container(height: 10),
                      LoginTextInput(
                        hint: "Password",
                        controller: passwordController,
                        keyboard: TextInputType.text,
                        obscureTxt: true,
                      ),
                      Container(height: 10),
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
                      Container(height: 10),
                      FacebookSignInButton(
                        onPressed: () {
                          facebookLogin();
                        },
                      ),
                      Container(height: 20),
                      Container(
                        height: 20,
                        child: RichText(
                          text: TextSpan(
                            text: 'Create Account',
                            style: TextStyle(color: Colors.white),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.push(context, 
                                platformPageRoute(
                                  maintainState: false,
                                  settings: RouteSettings(name: "CreateAccountPage"),
                                  builder: (BuildContext context) {
                                    return new CreateAccountPage();
                                  },
                                  fullscreenDialog: true,
                                  context: context,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(height: 20),
                      Container(
                        height: 20,
                        child: RichText(
                          text: TextSpan(
                            text: 'Reset Account',
                            style: TextStyle(color: Colors.white),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.push(context, 
                                platformPageRoute(maintainState: false,
                                  settings: RouteSettings(name: "ResetAccountPage"),
                                  builder: (BuildContext context) {
                                    return new ResetAccountPage();
                                  },
                                  fullscreenDialog: true,
                                  context: context,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'By logging in you agree to our',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Terms of Use',
                                style: TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                    launch('https://www.savourdeals.com/terms-of-use');
                                },
                              ),
                              TextSpan(
                                text: ' and ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launch('https://www.savourdeals.com/privacy-policy');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PlatformCircularProgressIndicator(),
              ],
            ),
          ),
          visible: _loading,
        )
      ],
    );
  }

  void login() {
    _onLoading();
    if (emailController.text.isEmpty || passwordController.text.isEmpty){
      // this removes the loading bar
      _endLoading();
      displayError("Missing email or password","Please provide both an email and password", "OK");
    } else {
      _auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text).catchError((error){
        // this removes the loading bar
        _endLoading();
        displayError("Login Failed!","Please check that your email and password are correct and try again.", "OK");
      }).then((authResult){
        FirebaseUser user = authResult.user;
        // this removes the loading bar
        _endLoading();
        if(user != null){
          if (!user.isEmailVerified){
            _auth.signOut();
            promptUnverified(user: user);
          }else{
            analytics.logLogin();
            analytics.setUserId(user.uid);
          }
        }else{
          _endLoading();
          displayError("Login Failed!","Please check that your email and password are correct and try again.", "OK");
        }
      });
    }
  }

  void facebookLogin() async {
    _onLoading();
    var facebook = new FacebookLogin();
    facebook.loginBehavior = FacebookLoginBehavior.nativeWithFallback;
    var result = await facebook.logIn(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        _auth.signInWithCredential(FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token)
        ).then((authResult) async {
          // this removes the loading bar
          if(authResult.additionalUserInfo.isNewUser){
            await analytics.logSignUp(
              signUpMethod: 'facebook',
            );
          }
          analytics.logLogin();
          analytics.setUserId(authResult.user.uid);
          _endLoading();
        });
        
        break;
      case FacebookLoginStatus.cancelledByUser:
        // this removes the loading bar
        _endLoading();
        break;
      case FacebookLoginStatus.error:
        // this removes the loading bar
        _endLoading();
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

  void _onLoading(){
    setState(() {
      if(this.mounted){
        _loading = true;
      }
    });
  }

  void _endLoading(){
    setState(() {
      if(this.mounted){
        _loading = false;
      }
    });
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
                Navigator.of(context).pop();
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
