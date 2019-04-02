part of tab_lib;

class ReferralPageWidget extends StatelessWidget {
  final String text;

  ReferralPageWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(this.text),
    );
  }
}