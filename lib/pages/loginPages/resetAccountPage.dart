import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/themes/decoration.dart';

class ResetAccountPage extends StatefulWidget {

  @override
  _ResetAccountPageState createState() => _ResetAccountPageState();
}

class _ResetAccountPageState extends State<ResetAccountPage> {

  TextEditingController emailController = new TextEditingController();
  bool _loading = false;
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(
      screenName: 'CreateAccountPage',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PlatformScaffold(
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
                        child: Text("Reset Password", style: whiteText),
                        onPressed: () {
                          _resetAccount();
                        },
                      ),
                      Container(padding: EdgeInsets.all(15)),
                      Container(
                        height: 20,
                        child: RichText(
                          text: TextSpan(
                            text: 'Back',
                            style: TextStyle(color: Colors.white),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
                              },
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

  void _resetAccount() {
    _onLoading();
    FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text).then((user) {
      // pop loading wheel
      _endLoading();
      // send user back
      Navigator.pop(context);
      _displayResetAccountSuccess();
    }).catchError((error) {
      displayError("Invalid Email Account", "Please enter a valid email account.", "OK");
    });
  }
  void displayError(title, message, buttonText){
    _endLoading();
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

  void _displayResetAccountSuccess() async {
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return PlatformAlertDialog(
          title: new Text("Reset Email Sent!"),
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