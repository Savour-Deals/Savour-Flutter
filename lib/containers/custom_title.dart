import 'package:flutter/cupertino.dart';

class SavourTitle extends StatelessWidget {
  SavourTitle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.40,
        ),
        child: Image.asset(
            "images/Savour_White.png",
            fit: BoxFit.cover
        )
    );
  }

}