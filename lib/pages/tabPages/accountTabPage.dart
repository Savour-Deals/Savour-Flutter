part of tab_lib;


class AccountPageWidget extends StatelessWidget {
  final String text;

  AccountPageWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Text(this.text),
      )
    );
  }
}