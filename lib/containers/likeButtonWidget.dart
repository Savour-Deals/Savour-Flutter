import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:firebase_database/firebase_database.dart';


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
    final user = await FirebaseAuth.instance.currentUser();
    final favoriteRef = FirebaseDatabase().reference().child("Users").child(user.uid).child("favorites").child(widget.deal.key);
    if (value){
      favoriteRef.set(widget.deal.key);
    }else{
      favoriteRef.remove();
    }
    setState(() {
      widget.deal.favorited = value;
    });
    widget.onFavoriteChanged(widget.deal.key, value);
  }
}