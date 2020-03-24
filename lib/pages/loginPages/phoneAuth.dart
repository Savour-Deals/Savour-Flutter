import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:savour_deals_flutter/themes/decoration.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:url_launcher/url_launcher.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PhoneAuth extends StatefulWidget {
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  final PageController _pageViewController = PageController();

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  BuildContext thisContext;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  bool _loading = false;

  String _verificationId;

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(
      screenName: 'PhoneAuthPage',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: PlatformScaffold(
            key: scaffoldKey,
            backgroundColor: Colors.black,
            body: Material(
              child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/login_background.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.45), BlendMode.srcATop
                  ),
                ),
              ),
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageViewController,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(18.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Image(image: AssetImage("images/Savour_Deals_White.png")),
                              Container(
                                child: const Text('Sign-in with your phone number'),
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                              ),
                              LoginTextInput(
                                hint: "Phone Number", 
                                prefix: Text("+1 "),
                                controller: _phoneNumberController,
                                keyboard: TextInputType.phone
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
                                child: Text("Send Text", style: whiteText),
                                onPressed: () {
                                  _verifyPhoneNumber();
                                },
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
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(18.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Image(image: AssetImage("images/Savour_Deals_White.png")),
                              Container(
                                child: const Text('Enter the code you recieved'),
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                              ),
                              LoginTextInput(
                                hint: "Verification Code", 
                                prefix: Text(""),
                                controller: _smsController,
                                keyboard: TextInputType.number
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
                                child: Text("Verify & Login", style: whiteText),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  final AuthCredential credential = PhoneAuthProvider.getCredential(
                                    verificationId: _verificationId,
                                    smsCode: _smsController.text,
                                  );
                                  _signInWithPhoneNumber(credential);
                                },
                              ),
                              Container(height: 20),
                              Container(
                                height: 20,
                                child: RichText(
                                  text: TextSpan(
                                    text: "Re-Send Text",
                                    style: TextStyle(color: Colors.white),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      _verifyPhoneNumber();
                                    },
                                  ),
                                ),
                              ),
                              Container(height: 10),
                              Container(
                                height: 20,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Back',
                                    style: TextStyle(color: Colors.white),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      _pageViewController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
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
                ],
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

  // Example code of how to verify phone number
  void _verifyPhoneNumber() async {
    _onLoading();
    FocusScope.of(context).unfocus();
    final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
      this._signInWithPhoneNumber(phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed = (AuthException authException) {
      _endLoading();
      displayError("Phone number verification failed", 'Code: ${authException.code}. Message: ${authException.message}', 'Okay');
    };

    final PhoneCodeSent codeSent = (String verificationId, [int forceResendingToken]) async {
      //send to next page
      _pageViewController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.ease);
      _verificationId = verificationId;
      _endLoading();
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
      _verificationId = verificationId;
      _endLoading();
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: "+1 " + _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  // Example code of how to sign in with phone.
  void _signInWithPhoneNumber(AuthCredential credential) async {
    _auth.signInWithCredential(credential).then((authResult) async {
      final FirebaseUser user = authResult.user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      if (user == null){
        displayError("Login Failed", "An unknown problem occured. Please try again later. If this persists, contact us for help.", "Okay");
      }else{
        // this removes the loading bar
        if(authResult.additionalUserInfo.isNewUser){
          await analytics.logSignUp(
            signUpMethod: 'PhoneAuth',
          );
        }
        analytics.logLogin();
        analytics.setUserId(authResult.user.uid);
        _endLoading();
      }
    });
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
}