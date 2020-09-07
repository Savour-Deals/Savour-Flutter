import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:savour_deals_flutter/containers/tou.dart';
import 'package:savour_deals_flutter/themes/decoration.dart';
import 'package:savour_deals_flutter/themes/theme.dart';

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
            body: Material(
              child: Container(
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
                              Image(image: AssetImage("images/Savour_Deals_FullColor.png")),
                              Container(
                                child: Text('Sign-in with your phone number:', 
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.center,
                              ),
                              LoginTextInput(
                                hint: "Phone Number", 
                                prefix: Text("+1 "),
                                controller: _phoneNumberController,
                                keyboard: TextInputType.phone
                              ),
                              Container(height: 40),
                              PlatformButton(
                                cupertino: (_,__) => CupertinoButtonData(
                                  pressedOpacity: 0.7,
                                ),
                                material: (_,__) => MaterialRaisedButtonData(
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
                              TermsOfUse(),
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
                              Image(image: AssetImage("images/Savour_Deals_FullColor.png")),
                              Container(
                                child: Text('Enter the code you recieved',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                padding: EdgeInsets.all(16),
                                alignment: Alignment.center,
                              ),
                              LoginTextInput(
                                hint: "Verification Code", 
                                prefix: Text(""),
                                controller: _smsController,
                                keyboard: TextInputType.number
                              ),
                              Container(height: 40),
                              PlatformButton(
                                cupertino: (_,__) => CupertinoButtonData(
                                  pressedOpacity: 0.7,
                                ),
                                material: (_,__) => MaterialRaisedButtonData(
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
                                    style: Theme.of(context).textTheme.bodyText1,
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      _verifyPhoneNumber();
                                    },
                                  ),
                                ),
                              ),
                              Container(height: 5),
                              Container(
                                height: 20,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Back',
                                    style: Theme.of(context).textTheme.bodyText1,
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      _pageViewController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                    },
                                  ),
                                ),
                              ),
                              Container(height: 20),
                              TermsOfUse(),
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

  void _verifyPhoneNumber() async {
    _onLoading();
    FocusScope.of(context).unfocus();
    final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
      this._signInWithPhoneNumber(phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
      _endLoading();
      if (!authException.message.contains("cancelled")){
        displayError("Phone number verification failed", 'Something happened. Please try again later.', 'Okay');
      }
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

  void _signInWithPhoneNumber(AuthCredential credential) async {
     _auth.signInWithCredential(credential).then((authResult) async {
      final User user = authResult.user;
      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
      if (user == null){
        displayError("Login Failed", "An unknown problem occured. Please try again later. If this persists, contact us for help.", "Okay");
      }else{
        // this removes the loading bar
        FirebaseDatabase().reference().child("Users").child(user.uid).child("phone_number").set(user.phoneNumber);
        if(authResult.additionalUserInfo.isNewUser){
          await analytics.logSignUp(
            signUpMethod: 'PhoneAuth',
          );
        }
        analytics.logLogin();
        analytics.setUserId(authResult.user.uid);
        _endLoading();
      }
    }).catchError((e) {
      PlatformException error = e;
      print(error.code);
      if (error.code == "ERROR_INVALID_VERIFICATION_CODE"){
        displayError("Invalid Code", "Please check the code and try again", "Okay");
      } else {
        displayError("Login Failed", "Login failed. Please try again. If this persists, contact us for help.", "Okay");
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
