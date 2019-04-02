part of tab_lib;

class VendorsPageWidget extends StatelessWidget {
  final String text;

  VendorsPageWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlatButton(
        color: SavourColorsMaterial.savourGreen,
        child: Text(
          "To Vendor Page",
          style: whiteText,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VendorPageWidget("Vendor Page")),
          );
        },
      ),
    );
  }
}