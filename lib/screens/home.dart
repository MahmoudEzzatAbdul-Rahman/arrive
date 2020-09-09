import 'package:Arrive/components/sidedrawer.dart';
import 'package:Arrive/utils/geofence.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import '../constants.dart';

bg.Geofence parseGeofence(dynamic location) {
  return new bg.Geofence(identifier: location["_id"], latitude: location["latitude"], longitude: location["longitude"], radius: kGeofenceRadius, notifyOnEntry: true, notifyOnExit: true);
}

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
//  HomeScreen({Key key, this.title}) : super(key: key);

//  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String ewelinkEmail;
  String ewelinkPassword;

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

    bool gate = prefs.getBool("gateSelected");
    bool lights = prefs.getBool("lightSelected");
    print('gate and lights $gate $lights');
    setState(() {
      if (gate) gateSelected = true;
      if (lights) lightSelected = true;
    });
    setGeofenceState(gate || lights);
  }

  void setGeofenceState(bool state) {
    if (state) {
      print('registering geofence $kHomeLocationId $kHomeLatitude $kHomeLongitude');
      GeofenceUtilities.registerNewGeofence({
        "_id": kHomeLocationId,
        "latitude": kHomeLatitude,
        "longitude": kHomeLongitude,
      });
      GeofenceUtilities.startGeofenceService();
    } else {
      GeofenceUtilities.stopGeofenceService();
    }
  }

  Future<bool> setGateSelected(bool b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (b)
      await prefs.setBool('gateSelected', true);
    else
      await prefs.setBool('gateSelected', false);
    return true;
  }

  Future<bool> setLightSelected(bool b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (b)
      await prefs.setBool('lightSelected', true);
    else
      await prefs.setBool('lightSelected', false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Arrive | Home sweet home',
        ),
      ),
      backgroundColor: kBackgroundColor,
      drawer: SideDrawer(),
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
                      'Garage gate ${gateSelected ? "will open once you get home" : ""}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: 25,
                        color: kBoldFontColor,
                      ),
                    ),
                  ),
                  ToggleButtons(
                    children: [Icon(Icons.home)],
                    isSelected: [gateSelected],
                    selectedColor: kButtonTextColor,
                    fillColor: kPrimaryColor,
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
                        color: kBoldFontColor,
                      ),
                    ),
                  ),
                  ToggleButtons(
                    children: [Icon(Icons.lightbulb_outline)],
                    isSelected: [lightSelected],
                    selectedColor: kButtonTextColor,
                    fillColor: kPrimaryColor,
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
