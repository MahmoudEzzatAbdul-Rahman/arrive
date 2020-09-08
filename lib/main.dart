import 'dart:convert';
import 'package:Arrive/customToast.dart';
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
  String _ewelinkEmail = prefs.getString('ewelinkEmail');
  String _ewelinkPassword = prefs.getString('ewelinkPassword');
  if (_ewelinkEmail == null || _ewelinkPassword == null) {
    LocalNotifications.send("Arrive", "Couldn't do geofence actions, missing ewelink credentials");
    return;
  }

  String gate = prefs.getString("gateSelected");
  String lights = prefs.getString("lightSelected");
  if (gate != null) devicesToToggle.add(kGarageGateDeviceId);
  if (lights != null) devicesToToggle.add(kGarageLightsDeviceId);

  print('devices to toggle $devicesToToggle $gate $lights');
  if (devicesToToggle.length > 0) LocalNotifications.send("Arrive", "Arrived home, devices to toggle $devicesToToggle");

  devicesToToggle.forEach((element) async {
    try {
      print('toggling device $element');
      var response = await http.post(kEwelinkEndpoint,
          body: json.encode({"deviceId": element, "ewelinkEmail": _ewelinkEmail, "ewelinkPassword": _ewelinkPassword}),
          headers: {"Accept": "*/*", "Content-Type": "application/json", "x-api-key": kLambdaAPIKey});
      var responseBody = json.decode(response.body);
      print("toggle response::: $responseBody");
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
  bool _settingsLoaded = false;
  String ewelinkEmail;
  String ewelinkPassword;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

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
    String _ewelinkEmail = prefs.getString('ewelinkEmail');
    String _ewelinkPassword = prefs.getString('ewelinkPassword');

    String gate = prefs.getString("gateSelected");
    String lights = prefs.getString("lightSelected");
    print('gate and lights $gate $lights');
//    await Future.delayed(Duration(seconds: 3));
    setState(() {
      if (gate != null) gateSelected = true;
      if (lights != null) lightSelected = true;
      if (_ewelinkEmail != null) ewelinkEmail = _ewelinkEmail;
      if (_ewelinkPassword != null) ewelinkPassword = _ewelinkPassword;
      _settingsLoaded = true;
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

  void loginEwelink(email, password) async {
    setState(() {
      _isLoading = true;
    });
    var response = await http
        .post(kEwelinkEndpoint, body: json.encode({"ewelinkEmail": email, "ewelinkPassword": password}), headers: {"Accept": "*/*", "Content-Type": "application/json", "x-api-key": kLambdaAPIKey});
    var responseBody = json.decode(response.body);
    print("ewelink login response::: $responseBody");
    if (responseBody["result"] != true || responseBody["error"] != null || responseBody["user"] == null) {
      CustomToast.showError(responseBody["message"] ?? responseBody["msg"] ?? "Login failed");
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('ewelinkEmail', email);
      prefs.setString('ewelinkPassword', password);
      setState(() {
        ewelinkEmail = email;
        ewelinkPassword = password;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void logoutEwelink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('ewelinkEmail');
    prefs.remove('ewelinkPassword');
    setState(() {
      ewelinkEmail = null;
      ewelinkPassword = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
//          style: TextStyle(
//            fontFamily: 'Pacifico',
//            fontSize: 25,
//          ),
        ),
      ),
      backgroundColor: Colors.teal[50],
      body: Center(
        child: !_settingsLoaded
            ? Center(
                child: CircularProgressIndicator(),
              )
            : (ewelinkEmail == null || ewelinkPassword == null)
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Please login to ewelink',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: 25,
                        color: Colors.teal[900],
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                          child: TextFormField(
                            decoration: InputDecoration(hintText: 'name@example.com'),
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter ewelink email';
                              }
                              Pattern pattern =
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                              RegExp regex = new RegExp(pattern);
                              if (!regex.hasMatch(value))
                                return 'Please enter a valid email';
                              else
                                return null;
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(50, 0, 50, 10),
                          child: TextFormField(
                            decoration: InputDecoration(hintText: 'password'),
                            controller: _passwordCtrl,
                            obscureText: true,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter ewelink password';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(50, 0, 50, 10),
                          child: Container(
                              height: 50,
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: RaisedButton(
                                textColor: Colors.white,
                                color: Colors.teal,
                                child: Text(_isLoading ? 'Logging in' : 'Login'),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
//                                print(_emailCtrl.text);
//                                print(_passwordCtrl.text);
                                    loginEwelink(_emailCtrl.text, _passwordCtrl.text);
                                  }
                                },
                              )),
                        ),
                        _isLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(),
                      ]),
                    ),
                  ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 80),
                        child: Container(
                          height: 40,
                          child: RaisedButton(
                            child: Text('Logout'),
                            textColor: Colors.white,
                            color: Colors.teal,
                            onPressed: logoutEwelink,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Garage gate ${gateSelected ? "will open once you get home" : ""}',
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
                                'Garage lights ${lightSelected ? "will turn on once you get home" : ""}',
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
