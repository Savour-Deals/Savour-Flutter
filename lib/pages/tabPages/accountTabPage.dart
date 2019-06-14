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

  @override
  void initState() { 
    super.initState();
    initialize();
  }

  void initialize() async {
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
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: Colors.white.withAlpha(0),
          brightness: Brightness.light,
          heroTag: "dealTab",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          backgroundColor: Colors.white.withAlpha(0),
          elevation: 0.0,
          brightness: Brightness.light,
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
        children: <Widget>[PlatformCircularProgressIndicator()],
      ):Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.height*0.2,
              height: MediaQuery.of(context).size.height*0.2,
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                image: new DecorationImage(
                  fit: BoxFit.contain,
                  image: getPhoto(),
                )
              )
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Welcome " + user.displayName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.people),
                ),
                title: Text("Click to invite more friends!"),
                contentPadding: EdgeInsets.all(8.0),
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
                  child: Icon(Icons.mail),
                ),
                title: Text("Contact Us"),
                contentPadding: EdgeInsets.all(8.0),
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
                  child: Icon(Icons.notifications_active),
                ),
                title: Text("Notifications"),
                contentPadding: EdgeInsets.all(8.0),
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
                  child: Icon(Icons.people),
                ),
                title: Text("Learn more about becoming a vendor!"),
                contentPadding: EdgeInsets.all(8.0),
                onTap: ()=> _launchURL('https://www.savourdeals.com/vendorsinfo'),
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.1), bottom: BorderSide(width: 0.1)),
              ),
            ),
            // Container(
            //   child: ListTile(
            //     leading: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Icon(
            //         Icons.power_settings_new,
            //         color: Colors.red,
            //       ),
            //     ),
            //     title: Text(
            //       "Logout",
            //       style: TextStyle(color: Colors.red),
            //     ),
            //     contentPadding: EdgeInsets.all(8.0),
            //     onTap: (){
            //       _auth.signOut();
            //     },
            //   ),
            //   decoration: BoxDecoration(
            //     border: Border( bottom: BorderSide(width: 0.1))
            //   ),
            // ),
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