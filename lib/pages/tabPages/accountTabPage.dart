part of tab_lib;


class AccountPageWidget extends StatelessWidget {
  final String text;

  AccountPageWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white.withAlpha(0),
        elevation: 0.0,
      ),
      body: Center(
        child: Text(this.text),
      )
    );
  }
}