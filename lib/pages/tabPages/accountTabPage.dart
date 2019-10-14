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

  //Declare contextual variables
  AppState appState;
  NotificationSettings notificationSettings;
  ThemeData theme;

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
    appState = Provider.of<AppState>(context);
    notificationSettings = Provider.of<NotificationSettings>(context);
    theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset("images/Savour_White.png"),
        ios: (_) => CupertinoNavigationBarData(
          backgroundColor: ColorWithFakeLuminance(appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen, withLightLuminance: true),
          heroTag: "dealTab",
          transitionBetweenRoutes: false,
        ),
        android: (_) => MaterialAppBarData(
          elevation: 0.0,
          brightness: Brightness.dark,
          backgroundColor: appState.isDark? theme.bottomAppBarColor:SavourColorsMaterial.savourGreen,
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
                  color: appState.isDark? Colors.white:Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.people,
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Click to invite more friends!",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
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
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Contact Us",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
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
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Notifications",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
                ),
                trailing: PlatformSwitch(
                  value: notificationSettings.isNotificationsEnabled,
                  onChanged: (value) {
                    _toggleNotifications();
                  },
                  // activeTrackColor: theme.primaryColor, 
                  activeColor: theme.primaryColor,
                ),
                // onTap: () => _toggleNotifications(),
                contentPadding: EdgeInsets.all(4.0),
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
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Learn more about becoming a vendor!",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
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
                    color: appState.isDark? Colors.white:Colors.black,
                  ),
                ),
                title: Text(
                  "Switch to " + (appState.isDark? "light":"dark") + " mode",
                  style: TextStyle(color: appState.isDark? Colors.white:Colors.black),
                ),
                contentPadding: EdgeInsets.all(4.0),
                onTap: () {
                  setState(() {
                    appState.setDarkMode(!appState.isDark);
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

  _toggleNotifications() async {
    if(notificationSettings.isNotificationsEnabled){
      _notificationPermissionHandler(false);
    }else{
      if(Platform.isIOS){
        OneSignal.shared.getPermissionSubscriptionState().then((subscriptionState){
          switch (subscriptionState.permissionStatus.status) {
            case OSNotificationPermission.authorized:
              //we have iOS permissions, resubscribe with onesignal
              _notificationPermissionHandler(true);
              break;
            case OSNotificationPermission.denied:
              // User denied previously, prompt them to go to settings
              // Accept/deny handled in tab.dart::didChangeAppLifecycleState
              _showSettingsDialog();
              break;
            default:
            // User was never prompted. WTH man!
              OneSignal.shared.promptUserForPushNotificationPermission().then((accepted){
                print("Accepted permission: $accepted");
                _notificationPermissionHandler(accepted);
              });
          }
        });
      }else{
        print("Accepted permission: Not needed for android");
        _notificationPermissionHandler(true);
      }
    }
  }

  Future _notificationPermissionHandler(bool accepted) async {
    if (accepted){
      print("Notifications turned on!");
      var user = await FirebaseAuth.instance.currentUser();
      Provider.of<NotificationSettings>(context).setNotificationsSetting(true);
      OneSignal.shared.setSubscription(true);
      if (user.email != null){
        OneSignal.shared.setEmail(email: user.email);
      }
    }else{
      print("Notifications turned off!");
      OneSignal.shared.setSubscription(false);
      notificationSettings.setNotificationsSetting(false);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text("Notification Permission Needed"),
          content: Text("Please turn on notifications in settings."),
          actions: <Widget>[
            FlatButton(
              child: Text("Go to Settings"),
              onPressed: () {
                AppSettings.openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Not Now", style: TextStyle(color: Colors.red),),
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