part of tab_lib;


class AccountPageWidget extends StatefulWidget {
  final  String text;
  AccountPageWidget(this.text);

  @override
  _AccountPageWidgetState createState() => _AccountPageWidgetState();
}

class _AccountPageWidgetState extends State<AccountPageWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  String userPhoto;
  SharedPreferences prefs;

  @override
  void initState() { 
    super.initState();
    initialize();
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance();
    _auth.currentUser().then((_userData) {
      setState(() {
        user = _userData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: MyInheritedWidget.of(context).data.isDark? Theme.of(context).bottomAppBarColor:SavourColorsMaterial.savourGreen,
          brightness: Theme.of(context).brightness,
          heroTag: "accountTab",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          backgroundColor: MyInheritedWidget.of(context).data.isDark? Theme.of(context).bottomAppBarColor:SavourColorsMaterial.savourGreen,
          elevation: 0.0,
          brightness: Theme.of(context).brightness,
        ),
        trailingActions: <Widget>[
          FlatButton(
            child: Text("Logout", style: TextStyle(color: Colors.red) ),
            color: Colors.transparent,
            onPressed: (){
              _auth.signOut();
            },
          )
        ],
      ),
      body: (user == null) ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center (
            child: PlatformCircularProgressIndicator()
          ),
        ],
      ):Center(
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8.0),
            ),
            Align(
              alignment: Alignment.center,
              child: ClipOval(
                child: Image(
                  fit: BoxFit.contain,
                  image: getPhoto(),
                  width: MediaQuery.of(context).size.height*0.2,
                  height: MediaQuery.of(context).size.height*0.2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Welcome " + user.displayName, 
                style: TextStyle(fontWeight: 
                  FontWeight.bold, 
                  fontSize: 20.0,
                  color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.people,
                    color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Click to invite more friends!",
                  style: TextStyle(color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                onTap: () =>{
                  Share.share("Check out Savour to get deals from local restaurants! https://www.savourdeals.com/getsavour")
                }
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1))
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.mail,
                    color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Contact Us",
                  style: TextStyle(color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                onTap: ()=> _launchURL('https://www.savourdeals.com/contact/'),
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1))
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications_active,
                    color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Notifications",
                  style: TextStyle(color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                // trailing: Slider(
                //   activeColor: SavourColorsMaterial.savourGreen,
                // ),
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1))
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.people,
                    color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Learn more about becoming a vendor!",
                  style: TextStyle(color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                onTap: ()=> _launchURL('https://www.savourdeals.com/vendorsinfo'),
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1), bottom: BorderSide(width: 0.1)),
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.lightbulb_outline,
                    color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Switch to " + (MyInheritedWidget.of(context).data.isDark? "light":"dark") + " mode",
                  style: TextStyle(color: MyInheritedWidget.of(context).data.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                onTap: () {
                  setState(() {
                    MyInheritedWidget.of(context).data.setDarkMode(!MyInheritedWidget.of(context).data.isDark);

                    // settings.isDark = !settings.isDark;
                    prefs.setBool('isDark', MyInheritedWidget.of(context).data.isDark);
                    // AppSettings.of(context).updateShouldNotify(AppSettings.of(context));
                    print("Dark : " + MyInheritedWidget.of(context).data.isDark.toString());
                  });
                },
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1), bottom: BorderSide(width: 0.1)),
              ),
            ),

          ],
        ),
      )
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  ImageProvider getPhoto(){
    if (user.photoUrl != null){
      return AdvancedNetworkImage(
          user.photoUrl,
          useDiskCache: true,
          fallbackAssetImage: "images/Savour_Deals_FullColor-white-back.png",
          retryLimit: 0,
      );
    }
    return AssetImage("images/Savour_Deals_FullColor-white-back.png");
  }
}