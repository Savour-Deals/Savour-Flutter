# fluter_geofire_example

Demonstrates how to use the fluter_geofire plugin.

## Getting Started

For Flutter plugins for other products, see [mrdishant@github](https://github.com/mrdishant)


    import 'dart:async';
    
    import 'package:flutter/material.dart';
    import 'package:flutter/services.dart';
    import 'package:flutter_geofire/flutter_geofire.dart';
       
    void main() => runApp(MyApp());
    
    class MyApp extends StatefulWidget {
      @override
      _MyAppState createState() => _MyAppState();
    }
     
    class _MyAppState extends State<MyApp> {
      List<String> keysRetrieved = [];
    
      @override
      void initState() {
        super.initState();
        initPlatformState();
      }
    
      // Platform messages are asynchronous, so we initialize in an async method.
      Future<void> initPlatformState() async {
        String pathToReference = "Sites";

    //Intializing geoFire
    Geofire.initialize(pathToReference);

    List<String> response;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      response = await Geofire.queryAtLocation(30.730743, 76.774948, 5);
    } on PlatformException {
      response = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      keysRetrieved = response;
    });
      }
      

      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          home: Scaffold(
              appBar: AppBar(
                title: const Text('Plugin example app'),
              ),
              body: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                  ),
                  Center(
                    child: keysRetrieved.length > 0
                        ? Text("First key is " +
                            keysRetrieved.first.toString() +
                            "\nTotal Keys " +
                            keysRetrieved.length.toString())
                        : CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: () {
                        setLocation();
                      },
                      color: Colors.blueAccent,
                      child: Text(
                        "Set Location",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: () {
                        setLocationFirst();
                      },
                      color: Colors.blueAccent,
                      child: Text(
                        "Set Location AsH28LWk8MXfwRLfVxgx",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: () {
                        getLocation();
                      },
                      color: Colors.blueAccent,
                      child: Text(
                        "Get Location AsH28LWk8MXfwRLfVxgx",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: () {
                        removeLocation();
                      },
                      color: Colors.blueAccent,
                      child: Text(
                        "Remove Location AsH28LWk8MXfwRLfVxgx",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )),
        );
      }
    
      void setLocation() async {
        bool response = await Geofire.setLocation(
            new DateTime.now().millisecondsSinceEpoch.toString(),
            30.730743,
            76.774948);

    print(response);
      }
      
      void setLocationFirst() async {
        bool response =
            await Geofire.setLocation("AsH28LWk8MXfwRLfVxgx", 30.730743, 76.774948);
    
        print(response);
      }
      
      void removeLocation() async {
        bool response = await Geofire.removeLocation("AsH28LWk8MXfwRLfVxgx");
    
        print(response);
      }
       
      void getLocation() async {
        Map<String, dynamic> response =
            await Geofire.getLocation("AsH28LWk8MXfwRLfVxgx");
    
        print(response);
      }
    }
