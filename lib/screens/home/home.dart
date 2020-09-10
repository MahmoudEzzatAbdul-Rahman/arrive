import 'package:Arrive/components/confirmdialogue.dart';
import 'package:Arrive/components/sidedrawer.dart';
import 'package:Arrive/models/ewelinkdevice.dart';
import 'package:Arrive/models/geofenceRule.dart';
import 'package:Arrive/screens/home/addGeofenceRule.dart';
import 'package:Arrive/screens/home/ruleListItem.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:Arrive/utils/ewelinkapi.dart';
import 'package:Arrive/utils/geofence.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
//  HomeScreen({Key key, this.title}) : super(key: key);

//  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GeofenceRules rulesList = new GeofenceRules();

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
    String gs = prefs.getString(kGeofenceRulesStorageKey);
    String userEmail = prefs.getString(kEwelinkEmailStorage);
    setState(() {
      if (gs != null) rulesList = GeofenceRules.fromString(gs);
      rulesList.rules = rulesList.rules.where((item) => item.userEmail == userEmail).toList();
      print(rulesList);
    });

    // legacy content
    bool gate = prefs.getBool("gateSelected");
    bool lights = prefs.getBool("lightSelected");
//    print('gate and lights $gate $lights');
    setState(() {
      if (gate) gateSelected = true;
      if (lights) lightSelected = true;
    });
    setGeofenceState(gate || lights);
  }

  void deleteRule(GeofenceRule rule) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    BlurryDialog alert = BlurryDialog(
      "",
      "Are you sure you want to delete this action?",
      "Delete",
      () {
        setState(() {
          rulesList.rules.removeWhere((element) => element.id == rule.id);
          prefs.setString(kGeofenceRulesStorageKey, rulesList.toString());
        });
      },
    );

    showDialog(context: context, builder: (BuildContext context) => alert);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(children: rulesList.rules.map((item) => RuleListItem(item, deleteRule)).toList()),
                SizedBox(
                  height: 40,
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AddGeofenceRuleScreen.routeName);
          if (result != null) getSettings();
        },
      ),
    );
  }
}
