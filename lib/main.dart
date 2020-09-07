import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'localNotifications.dart';

void bgHeadless(bg.HeadlessEvent headlessEvent) async {
  print(' --> $headlessEvent');
  switch (headlessEvent.name) {
    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
      if (geofenceEvent.action == 'ENTER' && geofenceEvent.identifier == '5f1a865f00374700083d3ae9') doGeofenceActions();
//      LocalNotifications.send("Arrive", "${geofenceEvent.action} ${geofenceEvent.identifier}");
//      GeofenceUtilities.notifyGeofenceEvent(geofenceEvent.action, geofenceEvent.identifier, message: "BG Geofence");
      print(geofenceEvent);
      break;
  }
}

void doGeofenceActions() async {
//  LocalNotifications.send("Arrive", "Arrived home, doing geofence actions");
  await DotEnv().load('.env');
  List<String> devicesToToggle = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String gate = prefs.getString("gateSelected");
  String lights = prefs.getString("lightSelected");
  if (gate != null) devicesToToggle.add(kGarageGateDeviceId);
  if (lights != null) devicesToToggle.add(kGarageLightsDeviceId);

  print('devices to toggle $devicesToToggle $gate $lights');
  if (devicesToToggle.length > 0) LocalNotifications.send("Arrive", "Arrived home, devices to toggle $devicesToToggle");

  devicesToToggle.forEach((element) async {
    try {
      print('toggling device $element');
      var response = await http.post(kEwelinkEndpoint, body: json.encode({"verifier": kEwelinkVerifier, "deviceId": element}), headers: {
        "Accept": "*/*",
        "Content-Type": "application/json",
      });
      var responseBody = json.decode(response.body);
      print("response::: $responseBody");
      LocalNotifications.send("Arrive", "Backend response $responseBody");
      prefs.remove('gateSelected');
      prefs.remove('lightSelected');
      bg.BackgroundGeolocation.stop();
    } catch (err) {
      print(err);
      LocalNotifications.send("Arrive", "Backend error $err");
      prefs.remove('gateSelected');
      prefs.remove('lightSelected');
      bg.BackgroundGeolocation.stop();
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load('.env');
  bg.BackgroundGeolocation.registerHeadlessTask(bgHeadless);
  runApp(MyApp());
}

bg.Geofence parseGeofence(dynamic location) {
  return new bg.Geofence(identifier: location["_id"], latitude: location["latitude"], longitude: location["longitude"], radius: kGeofenceRadius, notifyOnEntry: true, notifyOnExit: true);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrive | Home sweet home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
//        backgroundColor: Colors.blueGrey[900],
      ),
      home: MyHomePage(title: 'Arrive | Home sweet home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool gateSelected = false;
  bool lightSelected = false;

  @override
  void initState() {
    super.initState();
    // TODO: add geofence
    getSettings();
  }

  void getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String gate = prefs.getString("gateSelected");
    String lights = prefs.getString("lightSelected");
    print('gate and lights $gate $lights');
    setState(() {
      if (gate != null) gateSelected = true;
      if (lights != null) lightSelected = true;
    });
    setGeofenceState(gate != null || lights != null);
  }

  void setGeofenceState(bool state) {
    if (state) {
      print('registering geofence $kHomeLocationId $kHomeLatitude $kHomeLongitude');
      bg.BackgroundGeolocation.addGeofence(parseGeofence({
        "_id": kHomeLocationId,
        "latitude": kHomeLatitude,
        "longitude": kHomeLongitude,
      }));
      bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
        print('[Geofence event] - ${event.toString()}');
        // Not firing from here, because opening the app at home triggers it!
        //      if (event.action == 'ENTER' && event.identifier == '5f1a865f00374700083d3ae9') doGeofenceActions();
//      LocalNotifications.send("Arrive", "${event.action} ${event.identifier}");
        //      GeofenceUtilities.notifyGeofenceEvent(event.action, event.identifier, message: "HS Geofence");
      });
      bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_MEDIUM,
        distanceFilter: 30,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: false,
        enableHeadless: true,
        geofenceModeHighAccuracy: true,
        stopTimeout: 1,
        logLevel: bg.Config.LOG_LEVEL_OFF, // LOG_LEVEL_OFF, LOG_LEVEL_VERBOSE
      )).then((bg.State state) {
        if (!state.enabled) {
          bg.BackgroundGeolocation.startGeofences();
        }
      });
    } else {
      bg.BackgroundGeolocation.stop();
    }
  }

  Future<bool> setGateSelected(bool b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (b)
      await prefs.setString('gateSelected', 'yes');
    else
      await prefs.remove('gateSelected');
    return true;
  }

  Future<bool> setLightSelected(bool b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (b)
      await prefs.setString('lightSelected', 'yes');
    else
      await prefs.remove('lightSelected');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.teal[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Garage gate ${gateSelected ? "will open once you get home" : "is idle"}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: 25,
                        color: Colors.teal[900],
                      ),
                    ),
                  ),
                  ToggleButtons(
                    children: [Icon(Icons.home)],
                    isSelected: [gateSelected],
                    onPressed: (index) async {
                      if (!gateSelected) {
                        // to enable this, you have to authenticate
                        var localAuth = LocalAuthentication();
//                        bool canCheckBiometrics = await localAuth.canCheckBiometrics;
//                        print('can check biometrics $canCheckBiometrics');
                        bool didAuthenticate = await localAuth.authenticateWithBiometrics(localizedReason: 'Please authenticate to enable garage gate');
                        if (!didAuthenticate) return;
                      }
                      setState(() {
                        gateSelected = !gateSelected;
                      });
                      await setGateSelected(gateSelected);
                      setGeofenceState(gateSelected || lightSelected);
                    },
//                borderRadius: BorderRadius.circular(50),
                    borderWidth: 2,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Garage lights ${lightSelected ? "will turn on once you get home" : "are idle"}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: 25,
                        color: Colors.teal[900],
                      ),
                    ),
                  ),
                  ToggleButtons(
                    children: [Icon(Icons.lightbulb_outline)],
                    isSelected: [lightSelected],
                    onPressed: (index) async {
                      if (!lightSelected) {
                        // to enable this, you have to authenticate
                        var localAuth = LocalAuthentication();
                        bool didAuthenticate = await localAuth.authenticateWithBiometrics(localizedReason: 'Please authenticate to enable garage lights');
                        if (!didAuthenticate) return;
                      }
                      setState(() {
                        lightSelected = !lightSelected;
                      });
                      await setLightSelected(lightSelected);
                      setGeofenceState(gateSelected || lightSelected);
                    },
                    borderWidth: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
