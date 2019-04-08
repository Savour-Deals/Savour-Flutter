part of tab_lib;

class FavoritesPageWidget extends StatelessWidget {
  final String text;

  FavoritesPageWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlatButton(
        color: SavourColorsMaterial.savourGreen,
        child: Text(
          "Just hold up a minute",
          style: whiteText,
        ),
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => DealPageWidget(null)
          //   ),
          // );
        },
      ),
    );
  }
}