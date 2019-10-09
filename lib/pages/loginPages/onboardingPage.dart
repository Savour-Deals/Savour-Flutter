import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:savour_deals_flutter/themes/theme.dart';

class OnboardingPage extends StatefulWidget {

  const OnboardingPage({Key key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  final List<Widget> introWidgetsList = <Widget>[
    Screen1(),
    Screen2(),
    Screen3(),
  ];

  PageController controller = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          PageView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: introWidgetsList.length,
            onPageChanged: (int page){
              getChangedPageAndMoveBar(page);
            },
            controller: controller,
            itemBuilder: (context,index){
              return introWidgetsList[index];
            },
          ),
          Stack(
            alignment: AlignmentDirectional.topStart,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 35),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < introWidgetsList.length; i++)
                      (i == currentPage)? circleBar(true): circleBar(false),
                  ],
                ),
              )
            ],
          ),
          Container(
            alignment: AlignmentDirectional.bottomEnd,
            margin: EdgeInsets.only(bottom: 35, right: 15),
            child: Visibility(
              visible: (currentPage == introWidgetsList.length - 1),
              child: FloatingActionButton(
                backgroundColor: SavourColorsMaterial.savourGreen,
                onPressed: (){
                  Navigator.pop(context);
                },
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(26))
                ),
                child: Icon(Icons.arrow_forward, color: Colors.white,),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget circleBar(bool isActive){
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: isActive? 12: 8,
      width: isActive? 12: 8,
      decoration: BoxDecoration(
        color: isActive? SavourColorsMaterial.savourGreen: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  void getChangedPageAndMoveBar(int page){
    setState(() {
      currentPage = page;
    });
  }
}

class Screen1 extends StatelessWidget {
  const Screen1({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      // child: child,
    );
  }
}

class Screen2 extends StatelessWidget {
  const Screen2({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      // child: child,
    );
  }
}

class Screen3 extends StatelessWidget {
  const Screen3({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      // child: child,
    );
  }
}