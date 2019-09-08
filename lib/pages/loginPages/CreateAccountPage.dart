import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/themes/decoration.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
class CreateAccountPage extends StatefulWidget {

  final FirebaseAuth auth;
  final GlobalKey<ScaffoldState> scaffoldKey;

  CreateAccountPage(this.auth, this.scaffoldKey);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();

}

class _CreateAccountPageState extends State<CreateAccountPage> {
  bool _passwordObscured = true;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController passwordConfirmController = new TextEditingController();

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
                    LoginTextInput(
                      hint: "Password Confirm",
                      controller: passwordConfirmController,
                      keyboard: TextInputType.text,
                      obscureTxt: _passwordObscured,
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
                        createAccount();
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
    void createAccount() {

      _onLoading();

      if (passwordConfirmController.text != passwordController.text) {
        displayError("The passwords do not match", "Re-enter passwords", "OK");
      } else if (emailController.text.isEmpty || passwordController.text.isEmpty || passwordConfirmController.text.isEmpty){
        displayError("Missing email or password","Please provide both an email and password", "OK");
      } else {
       this.widget.auth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text).catchError((error) {
         displayError("Account Creation Failed!","Sorry, the account could not be created.", "OK");

       }).then((user) {
          //TODO: Handle account creation with a re-route to the login page, and a message to confirm email

         // this removes the loading bar
         Navigator.pop(context);

         // this removes the create account page and takes the user back to the login page
         Navigator.pop(context);


//         Navigator.push(context, platformPageRoute(maintainState: false,
//         builder: (BuildContext context) {
//           return new LoginPage("Please check your email to authenticate your account.");
//         },
//         fullscreenDialog: true
//         ));


       });
      }
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

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CircularProgressIndicator(),
        ],
      )
    );
  }
}

