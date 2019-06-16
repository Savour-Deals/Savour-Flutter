part of tab_lib;

class MapPageWidget extends StatefulWidget {
  final text;
  MapPageWidget(this.text);

  @override
  _MapPageWidgetState createState() => _MapPageWidgetState();
}

class _MapPageWidgetState extends State<MapPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(widget.text),
    );
  }
}
