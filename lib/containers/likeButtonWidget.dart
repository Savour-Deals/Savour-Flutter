import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/icons/savour_icons_icons.dart';
import 'package:savour_deals_flutter/stores/deal_model.dart';
import 'package:firebase_database/firebase_database.dart';


class LikeButton extends StatefulWidget{
  final Deal deal;

  LikeButton(this.deal);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    
    if (widget.deal.favorited){
      return IconButton(
        icon: Icon(SavourIcons.filled_heart,
          color: Colors.red,
        ), onPressed: () {
          setFavorite(false);
        },
      );
    }
    return IconButton(
      icon: Icon(SavourIcons.icons8_like_2,
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
      setState(() {
        widget.deal.favorited = value;
      });
    }else{
      favoriteRef.remove();
      setState(() {
        widget.deal.favorited = value;
      });
    }
  }
}