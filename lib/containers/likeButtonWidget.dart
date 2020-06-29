import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:savour_deals_flutter/utils.dart' as globals;

class LikeButton extends StatefulWidget{
  final Deal deal;
  final Function(String, bool) onFavoriteChanged;

  LikeButton({@required this.deal, @required this.onFavoriteChanged});

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.deal.favorited){
      return IconButton(
        icon: Image.asset('images/like_filled.png',
          width: 25,
          height: 25,
          color: Colors.red,
        ), onPressed: () {
          setFavorite(false);
        },
      );
    }
    return IconButton(
      icon: Image.asset('images/like.png',
        width: 25,
        height: 25,
        color: Colors.red,
      ), onPressed: () {
        setFavorite(true);
      },
    );
  }

  void setFavorite(bool value) async {
    setState(() {
      widget.deal.favorited = value;
    });
    globals.dealsApiProvider.setFavorite(widget.deal.key, value);
    // widget.onFavoriteChanged(widget.deal.key, value);
  }
}