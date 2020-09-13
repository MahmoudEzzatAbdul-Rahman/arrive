import 'package:Arrive/models/geofenceRule.dart';
import 'package:Arrive/models/place.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';

import 'constants.dart';
import 'ewelinkapi.dart';
import 'localNotifications.dart';

void backgroundGeofenceHeadlessTask(HeadlessEvent headlessEvent) async {
  print(' --> $headlessEvent');
  switch (headlessEvent.name) {
    case Event.GEOFENCE:
      GeofenceEvent geofenceEvent = headlessEvent.event;
      await DotEnv().load('.env');
      doGeofenceActions(geofenceEvent.action, geofenceEvent.identifier);
//      if (geofenceEvent.action == 'ENTER' && geofenceEvent.identifier == kHomeLocationId) doGeofenceActions();
//      LocalNotifications.send("Arrive", "${geofenceEvent.action} ${geofenceEvent.identifier}");
//      GeofenceUtilities.notifyGeofenceEvent(geofenceEvent.action, geofenceEvent.identifier, message: "BG Geofence");
      print(geofenceEvent);
      break;
  }
}

void doGeofenceActions(String event, String identifier) async {
  print('Arrived, geofence event $event id is $identifier');
//  LocalNotifications.send("Arrive", "Arrived home, doing geofence actions");
  List<String> deviceIdsToToggle = [];
  List<String> devicesToToggle = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  String _ewelinkEmail = prefs.getString(kEwelinkEmailStorage);
  String _ewelinkPassword = prefs.getString(kEwelinkPasswordStorage);
  if (_ewelinkEmail == null || _ewelinkPassword == null) {
    LocalNotifications.send("Arrive", "Couldn't do geofence actions, missing ewelink credentials");
    return;
  }

  GeofenceRules rulesList = new GeofenceRules();
  String gs = prefs.getString(kGeofenceRulesStorageKey);
  if (gs != null) rulesList = GeofenceRules.fromString(gs);
  rulesList.rules = rulesList.rules.where((item) => item.userEmail == _ewelinkEmail).toList();
  GeofenceRules rulesListForEvent = new GeofenceRules(rules: rulesList.rules.where((item) => item.active && item.event == event && item.place.id == identifier).toList());
  print('filtered rules ${rulesListForEvent.rules}');
  rulesListForEvent.rules.forEach((rule) {
    devicesToToggle.add(rule.device.name);
    if (rule.device.deviceId != null) deviceIdsToToggle.add(rule.device.deviceId);

    if (!rule.persistAfterAction) rule.active = false;
  });
  await prefs.setString(kGeofenceRulesStorageKey, rulesList.toString());
  GeofenceUtilities.checkGeofenceRules(doNotEnableService: true);

  if (deviceIdsToToggle.length > 0) LocalNotifications.send("Arrive", "Arrived home, devices to toggle $devicesToToggle");
//  else
//    LocalNotifications.send("Arrive", "Unexpected behaviour, toggling nothing");

  rulesListForEvent.rules.forEach((rule) async {
    try {
      String deviceId = rule.device.deviceId;
      if (deviceId == null) return;
      print('toggling device ${rule.device.name}');
      var responseBody = await EwelinkAPI.post({
        'requestMethod': 'toggleDevice',
        "deviceId": deviceId,
      });
      print("toggle response::: $responseBody");
      if (responseBody["result"] == true && responseBody["status"] == 'ok') {
        if (rule.secondToggle && rule.secondToggleTimeout > 0) {
          await Future.delayed(Duration(seconds: rule.secondToggleTimeout));
          print('toggling device ${rule.device.name} for the second time');
          var secondResponseBody = await EwelinkAPI.post({
            'requestMethod': 'toggleDevice',
            "deviceId": deviceId,
          });
          print("toggle response::: $secondResponseBody");
        }
      }
      LocalNotifications.send("Arrive", "Backend response $responseBody");
    } catch (err) {
      print(err);
      LocalNotifications.send("Arrive", "Backend error $err");
    }
  });
}

class GeofenceUtilities {
  static void startGeofenceService({List<Place> toAdd}) async {
    BackgroundGeolocation.onGeofence((GeofenceEvent event) {
      print('[Geofence event] - ${event.toString()}');
      // Not firing from here, because opening the app at home triggers it!
      // if (event.action == 'ENTER' && event.identifier == '5f1a865f00374700083d3ae9') doGeofenceActions();
      // LocalNotifications.send("Arrive", "${event.action} ${event.identifier}");
      // GeofenceUtilities.notifyGeofenceEvent(event.action, event.identifier, message: "HS Geofence");
    });
    BackgroundGeolocation.ready(Config(
      notification: Notification(smallIcon: '@drawable/ic_stat_a'),
      desiredAccuracy: Config.DESIRED_ACCURACY_MEDIUM,
//      distanceFilter: 30,
      stopOnTerminate: false,
      startOnBoot: true,
      debug: false,
      enableHeadless: true,
      geofenceModeHighAccuracy: true,
      stopTimeout: 1,
      logLevel: Config.LOG_LEVEL_OFF, // LOG_LEVEL_OFF, LOG_LEVEL_VERBOSE
    )).then((State state) async {
      if (!state.enabled) {
        await BackgroundGeolocation.startGeofences();
        if (toAdd.length > 0) print('adding geofence $toAdd');
        if (toAdd.length > 0) await addGeofences(toAdd.map(parsePlaceToGeofence).toList());
      }
    });
  }

  static void stopGeofenceService() async {
    BackgroundGeolocation.stop();
  }

  static Future<bool> checkGeofenceRules({bool doNotEnableService = false /* when called from headless */}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    GeofenceRules rulesList = new GeofenceRules();
    String gs = prefs.getString(kGeofenceRulesStorageKey);
    String userEmail = prefs.getString(kEwelinkEmailStorage);
    if (userEmail == null) {
      stopGeofenceService();
      return false;
    }
    if (gs != null) rulesList = GeofenceRules.fromString(gs);
    rulesList.rules = rulesList.rules.where((item) => item.userEmail == userEmail).toList();

    List<Geofence> geofences = await BackgroundGeolocation.geofences;
    var registeredGeofences = geofences.map((Geofence goefence) => goefence.identifier);
    List<Place> toAdd = [];

    bool atLeastOneRuleIsActive = false;
    List<String> validPlacesIds = [];
    rulesList.rules.forEach((rule) {
      if (rule.active) {
        atLeastOneRuleIsActive = true;
        if (!validPlacesIds.contains(rule.place.id)) {
          if (!registeredGeofences.contains(rule.place.id)) {
            toAdd.add(rule.place);
          }
          validPlacesIds.add(rule.place.id);
        }
      }
    });
//    if (toAdd.length > 0) await addGeofences(toAdd.map(parsePlaceToGeofence).toList()); // doing this after starting the service
    registeredGeofences.forEach((element) async {
      if (!validPlacesIds.contains(element)) {
        removeGeofence(element);
      }
    });
    if (atLeastOneRuleIsActive && !doNotEnableService)
      startGeofenceService(toAdd: toAdd);
    else if (!atLeastOneRuleIsActive) {
      stopGeofenceService();
      print('stopping geo service!');
//      LocalNotifications.send('Arrive', 'Stopping goefence service');
    }
    return atLeastOneRuleIsActive;
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

  static Future<dynamic> addGeofence(Place place) async {
    return BackgroundGeolocation.addGeofence(parsePlaceToGeofence(place));
  }

  static Future<dynamic> removeGeofence(String locationId) async {
    return BackgroundGeolocation.removeGeofence(locationId);
  }

  static Future<dynamic> removeAllGeofences() async {
    return BackgroundGeolocation.removeGeofences();
  }

  static Future<dynamic> getAllGeofences() async {
    return BackgroundGeolocation.geofences;
  }

  static Geofence parseGeofence(dynamic location) {
    return new Geofence(identifier: location["_id"], latitude: location["latitude"], longitude: location["longitude"], radius: kGeofenceRadius, notifyOnEntry: true, notifyOnExit: true);
  }

  static Geofence parsePlaceToGeofence(Place place) {
    return new Geofence(
      identifier: place.id,
      latitude: place.latitude,
      longitude: place.longitude,
      radius: kGeofenceRadius,
      notifyOnEntry: true,
      notifyOnExit: true,
    );
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
