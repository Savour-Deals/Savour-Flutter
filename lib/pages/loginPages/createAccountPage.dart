import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/themes/decoration.dart';

class CreateAccountPage extends StatefulWidget {


  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();

}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController passwordConfirmController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return PlatformScaffold(
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
                  Container(padding: EdgeInsets.all(5)),
                  LoginTextInput(
                    hint: "Password Confirm",
                    controller: passwordConfirmController,
                    keyboard: TextInputType.text,
                    obscureTxt: true,
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
                    child: Text("Create Account", style: whiteText),
                    onPressed: () {
                      _createAccount();
                    },
                  ),
                  Container(padding: EdgeInsets.all(15)),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 25.0,
                      child: Center(
                        child: Text("Back", 
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                          textAlign: TextAlign.center,
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
        user = await _auth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      } catch (error) {
        PlatformException exception = error;
        if (exception.code == "ERROR_WEAK_PASSWORD") {
          _displayError("Account Creation Failed!",exception.message, "OK");
        } else {
          _displayError("Account Creation Failed!","Sorry, the account could not be created.", "OK");
        }
        return;
      }
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      var userRef = FirebaseDatabase.instance.reference().child("Users").child(user.uid);
      userUpdateInfo.displayName = "";//set these blank for now
      userRef.child("full_name").set("");
      userRef.child("email").set(emailController.text);
      user.updateProfile(userUpdateInfo);

      // this removes the loading bar
      Navigator.pop(context);
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
    Navigator.pop(context);
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

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new PlatformCircularProgressIndicator(),
        ],
      )
    );
  }
}

