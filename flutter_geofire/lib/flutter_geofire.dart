import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class Geofire {
    MethodChannel _channel = const MethodChannel('geofire');
    EventChannel eventChannel = EventChannel('geofirestream');
    Function _onEntered, _onExited;

  Future<bool> initialize(String path, Function cbEntered, Function cbExited) async {
    final dynamic r = await _channel.invokeMethod('GeoFire.start', <String, dynamic>{"path": path});
    _onEntered = cbEntered;
    _onExited = cbExited;
    return r ?? false;
  }

  void _onEvent(Object event) {
    var jsonData = event as String;
    var data = json.decode(jsonData);
    if (data["event"] == "ENTERED" && _onEntered != null){
      _onEntered(data);
    }else if (data["event"] == "EXITED" && _onExited != null){
      _onExited(data);
    }
  }

  void _onError(Object error) {
    //TODO: Improve API for errors
  }

  Future<bool> setLocation(
      String id, double latitude, double longitude) async {
    final bool isSet = await _channel.invokeMethod('setLocation',
        <String, dynamic>{"id": id, "lat": latitude, "lng": longitude});
    return isSet;
  }

  Future<bool> removeLocation(String id) async {
    final bool isSet = await _channel
        .invokeMethod('removeLocation', <String, dynamic>{"id": id});
    return isSet;
  }

  Future<Map<String, dynamic>> getLocation(String id) async {
    final Map<dynamic, dynamic> response =
        await _channel.invokeMethod('getLocation', <String, dynamic>{"id": id});

    Map<String, dynamic> location = new Map();

    response.forEach((key, value) {
      location[key] = value;
    });
    return location;
  }

  Future<String> queryAtLocation(
    double lat, double lng, double radius) async {
    final dynamic response = await _channel.invokeMethod(
        'queryAtLocation', {"lat": lat, "lng": lng, "radius": radius});
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    String r = response.toString();
    return r;
  }

  Future<String> updateLocation(
    double lat, double lng, double radius) async {
    final dynamic response = await _channel.invokeMethod(
        'updateLocation', {"lat": lat, "lng": lng, "radius": radius});
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    String r = response.toString();
    return r;
  }


}
