import 'package:flutter/material.dart';
import 'package:savour_deals_flutter/themes/theme.dart';
import 'package:savour_deals_flutter/icons/savour_icons_icons.dart';
import 'package:savour_deals_flutter/pages/tabPages/tablib.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SavourTabPage extends StatefulWidget {
  SavourTabPage({Key key, this.uid}) : super(key: key);
  final String title = 'Savour Deals';
  final String uid;

  @override
  _SavourTabPageState createState() => _SavourTabPageState();
}

class _SavourTabPageState extends State<SavourTabPage> {
  int _currentIndex = 0;
  List<Widget> _children = [
    DealsPageWidget("Deals Page"),
    FavoritesPageWidget("Favorites Page"),
    VendorsPageWidget("Vendors Page"),
    AccountPageWidget("Accounts Page"),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  IndexedStack(
        index: _currentIndex,
        children: _children,
      ),//_children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, 
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: Icon(SavourIcons.icons8_price_tag_2,
              color: savourMaterialThemeData.primaryColor,
            ),
            activeIcon: Icon(SavourIcons.icons8_price_tag_filled,
              color: savourMaterialThemeData.primaryColor,
            ),
            title: Text('Deals',
              style: TextStyle(color: savourMaterialThemeData.primaryColor),
            )
          ),
          BottomNavigationBarItem(
            icon: Icon(SavourIcons.icons8_like_2,
              color: savourMaterialThemeData.primaryColor,
            ),
            activeIcon: Icon(SavourIcons.filled_heart,
              color: savourMaterialThemeData.primaryColor,
            ),
            title: Text('Favorites',
              style: TextStyle(color: savourMaterialThemeData.primaryColor),
            )
          ),
          BottomNavigationBarItem(
            icon: Icon(SavourIcons.icons8_small_business,
              color: savourMaterialThemeData.primaryColor,
            ),
            activeIcon: Icon(SavourIcons.icons8_small_business_filled,
              color: savourMaterialThemeData.primaryColor,
            ),
            title: Text('Vendors',
              style: TextStyle(color: savourMaterialThemeData.primaryColor),
            )
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(SavourIcons.),
          //   activeIcon: Icon(SavourIcons.,
            //   color: savourMaterialThemeData.primaryColor,
            // ),
          //   title: Text('Referral',
            //   style: TextStyle(color: Colors.black),
            // )
          // ),
          BottomNavigationBarItem(
            icon: Icon(SavourIcons.icons8_user_male_circle,
              color: savourMaterialThemeData.primaryColor,
            ),
            activeIcon: Icon(SavourIcons.icons8_user_male_circle_filled,
              color: savourMaterialThemeData.primaryColor,
            ),
            title: Text('Account',
              style: TextStyle(color: savourMaterialThemeData.primaryColor),
            )
          )
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
