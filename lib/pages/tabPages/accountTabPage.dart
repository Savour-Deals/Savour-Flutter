part of tab_lib;


class AccountPageWidget extends StatelessWidget {
  final String text;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AccountPageWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white.withAlpha(0),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton(
            child: Text("Logout", style: TextStyle(color: Colors.red) ),
            color: Colors.white.withAlpha(0),
            
            onPressed: (){
              _auth.signOut();
            },
          )
        ],
      ),
      body: Center(
        child: Text(this.text),
      )
    );
  }
}