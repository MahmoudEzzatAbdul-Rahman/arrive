import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'localNotifications.dart';

void backgroundGeofenceHeadlessTask(HeadlessEvent headlessEvent) async {
  print(' --> $headlessEvent');
  switch (headlessEvent.name) {
    case Event.GEOFENCE:
      GeofenceEvent geofenceEvent = headlessEvent.event;
      await DotEnv().load('.env');
      if (geofenceEvent.action == 'ENTER' && geofenceEvent.identifier == kHomeLocationId) doGeofenceActions();
//      LocalNotifications.send("Arrive", "${geofenceEvent.action} ${geofenceEvent.identifier}");
//      GeofenceUtilities.notifyGeofenceEvent(geofenceEvent.action, geofenceEvent.identifier, message: "BG Geofence");
      print(geofenceEvent);
      break;
  }
}

void doGeofenceActions() async {
//  LocalNotifications.send("Arrive", "Arrived home, doing geofence actions");
  List<String> devicesToToggle = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String _ewelinkEmail = prefs.getString('ewelinkEmail');
  String _ewelinkPassword = prefs.getString('ewelinkPassword');
  if (_ewelinkEmail == null || _ewelinkPassword == null) {
    LocalNotifications.send("Arrive", "Couldn't do geofence actions, missing ewelink credentials");
    return;
  }

  bool gate = prefs.getBool("gateSelected");
  bool lights = prefs.getBool("lightSelected");
  if (gate) devicesToToggle.add(kGarageGateDeviceId);
  if (lights) devicesToToggle.add(kGarageLightsDeviceId);

  print('devices to toggle $devicesToToggle $gate $lights');
  if (devicesToToggle.length > 0)
    LocalNotifications.send("Arrive", "Arrived home, devices to toggle $devicesToToggle");
  else
    LocalNotifications.send("Arrive", "Unexpected behaviour, toggling nothing");

  devicesToToggle.forEach((element) async {
    try {
      print('toggling device $element');
      var response = await http.post(kEwelinkEndpoint,
          body: json.encode({"deviceId": element, "ewelinkEmail": _ewelinkEmail, "ewelinkPassword": _ewelinkPassword}),
          headers: {"Accept": "*/*", "Content-Type": "application/json", "x-api-key": kLambdaAPIKey});
      var responseBody = json.decode(response.body);
      print("toggle response::: $responseBody");
      LocalNotifications.send("Arrive", "Backend response $responseBody");
      await prefs.setBool('gateSelected', false);
      await prefs.setBool('lightSelected', false);
      BackgroundGeolocation.stop();
    } catch (err) {
      print(err);
      LocalNotifications.send("Arrive", "Backend error $err");
      await prefs.setBool('gateSelected', false);
      await prefs.setBool('lightSelected', false);
      BackgroundGeolocation.stop();
    }
  });
}

class GeofenceUtilities {
  static void startGeofenceService() async {
    BackgroundGeolocation.onGeofence((GeofenceEvent event) {
      print('[Geofence event] - ${event.toString()}');
      // Not firing from here, because opening the app at home triggers it!
      // if (event.action == 'ENTER' && event.identifier == '5f1a865f00374700083d3ae9') doGeofenceActions();
      // LocalNotifications.send("Arrive", "${event.action} ${event.identifier}");
      // GeofenceUtilities.notifyGeofenceEvent(event.action, event.identifier, message: "HS Geofence");
    });
    BackgroundGeolocation.ready(Config(
      desiredAccuracy: Config.DESIRED_ACCURACY_MEDIUM,
      distanceFilter: 30,
      stopOnTerminate: false,
      startOnBoot: true,
      debug: false,
      enableHeadless: true,
      geofenceModeHighAccuracy: true,
      stopTimeout: 1,
      logLevel: Config.LOG_LEVEL_OFF, // LOG_LEVEL_OFF, LOG_LEVEL_VERBOSE
    )).then((State state) {
      if (!state.enabled) {
        BackgroundGeolocation.startGeofences();
      }
    });
  }

  static void stopGeofenceService() async {
    BackgroundGeolocation.stop();
  }

  static Future<Location> getCurrentLocation() async {
    return await BackgroundGeolocation.getCurrentPosition();
  }

  static Future<dynamic> registerNewGeofence(dynamic location) async {
    return BackgroundGeolocation.addGeofence(parseGeofence(location));
  }

  static Future<dynamic> addGeofences(List<Geofence> geofences) async {
    return BackgroundGeolocation.addGeofences(geofences);
  }

  static Future<dynamic> removeGeofence(String locationId) async {
    return BackgroundGeolocation.removeGeofence(locationId);
  }

  static Future<dynamic> removeAllGeofences() async {
    return BackgroundGeolocation.removeGeofences();
  }

  static Geofence parseGeofence(dynamic location) {
    return new Geofence(identifier: location["_id"], latitude: location["latitude"], longitude: location["longitude"], radius: kGeofenceRadius, notifyOnEntry: true, notifyOnExit: true);
  }

//  static Future<dynamic> getUserLocations() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    var encoded = prefs.getString("currentUser");
//    if (encoded == null) return null;
//    var res = await LocationAPIs.getUserLocations();
//    return res["locations"];
//  }

//  static Future<dynamic> refreshUserGeofences() async {
//    List<Geofence> geofences = await BackgroundGeolocation.geofences;
//    print('[getGeofences: $geofences');
//    var registeredGeofences = geofences.map((Geofence goefence) => goefence.identifier);
//
//    var userLocations = await getUserLocations();
//    if (userLocations == null) userLocations = [];
//    var locids = userLocations.map((e) => e["_id"]);
//    List<Geofence> toAdd = [];
//    for (var loc in userLocations) {
//      if (!registeredGeofences.contains(loc["_id"])) {
//        print('registering new geofence ${loc.toString()}');
////        await registerNewGeofence(loc);
//        toAdd.add(parseGeofence(loc));
//      }
//    }
//    if (toAdd.length > 0) await addGeofences(toAdd);
//    registeredGeofences.forEach((element) {
//      if (!locids.contains(element)) {
//        removeGeofence(element);
//      }
//    });
//    print('Refreshed current geofences');
//  }

//  static void notifyGeofenceEvent(String type /*entry or exit*/, String identifier, {String message}) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    var user = json.decode(prefs.getString("currentUser"));
//    if (user == null) return null;
//    String userId = user["_id"];
//
//    Map<String, dynamic> geofenceEvent = {"user": userId, "location": identifier, "event": type};
//    var r = await LocationAPIs.postGeofenceEvent(geofenceEvent);
//    print('posting geofence event result $r');
//
//    print('getting location $type $identifier');
//    var res = await LocationAPIs.getLocation(identifier);
//    print('yay ${res.toString()}');
//    if (res == null) return;
//    if (res["result"] == true) {
//      var location = res["location"];
//      if (location == null) {
//        LocalNotifications.send('Beam', '${message ?? "Geofence"} $type <Unknown location>');
//        return;
//      }
//      LocalNotifications.send('Beam', '${message ?? "Geofence"} $type ${location["name"]}');
//    }
//  }
}
