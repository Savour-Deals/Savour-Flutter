
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/themes/decoration.dart';

class ResetAccountPage extends StatefulWidget {
  final FirebaseAuth auth;

  ResetAccountPage(this.auth);

  @override
  _ResetAccountPageState createState() => _ResetAccountPageState();
}

class _ResetAccountPageState extends State<ResetAccountPage> {

  TextEditingController emailController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                    child: Text("Reset Password", style: whiteText),
                    onPressed: () {
                      _resetAccount();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetAccount() {
    this.widget.auth.sendPasswordResetEmail(email: emailController.text).then((user) {
      Navigator.pop(context);
    }).catchError((error) {
      displayError("Invalid Email Account", "Please enter a valid email account.", "OK");

    });
  }
  void displayError(title, message, buttonText){

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
}