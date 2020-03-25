import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse() : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
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
        )
      ],
    );
  }
}