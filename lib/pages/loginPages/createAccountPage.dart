import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart'
  hide BuildContext;
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/themes/decoration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class CreateAccountPage extends StatefulWidget {


  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();

}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController passwordConfirmController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
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
                      LoginTextInput(
                        hint: "Password",
                        controller: passwordController,
                        keyboard: TextInputType.text,
                        obscureTxt: true,
                      ),
                      Container(height: 10),
                      LoginTextInput(
                        hint: "Password Confirm",
                        controller: passwordConfirmController,
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
                        child: Text("Create Account", style: whiteText),
                        onPressed: () {
                          _createAccount();
                        },
                      ),
                      Container(height: 15),
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
                      Container(height: 15),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'By signing up you agree to our',
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

  void _createAccount() async {

    _onLoading();

    if (passwordConfirmController.text != passwordController.text) {
      _displayError("The passwords do not match", "Re-enter passwords", "OK");
    } else if (emailController.text.isEmpty || passwordController.text.isEmpty || passwordConfirmController.text.isEmpty){
      _displayError("Missing email or password","Please provide both an email and password", "OK");
    } else {
      FirebaseUser user;
      try {
        var authResult = await _auth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
        user = authResult.user;
      } catch (error) {
        PlatformException exception = error;
        if (exception.code == "ERROR_WEAK_PASSWORD") {
          _displayError("Account Creation Failed!",exception.message, "OK");
        } else {
          _displayError("Account Creation Failed!","Sorry, the account could not be created.", "OK");
        }
        return;
      }
      await analytics.logSignUp(
        signUpMethod: 'email',
      );
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      var userRef = FirebaseDatabase.instance.reference().child("Users").child(user.uid);
      userUpdateInfo.displayName = "";//set these blank for now
      userRef.child("full_name").set("");
      userRef.child("email").set(emailController.text);
      user.updateProfile(userUpdateInfo);

      // this removes the loading bar
      _endLoading();
      //This sends the user back
      Navigator.pop(context);
      user.sendEmailVerification();
      _displayCreateAccountSuccess();
    }
  }
  void _displayCreateAccountSuccess() async {
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
  
  void _displayError(title, message, buttonText){
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
            new PlatformDialogAction(
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
      _loading = true;
    });
  }

  void _endLoading(){
    setState(() {
      _loading = false;
    });
  }
}

