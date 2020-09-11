import 'package:Arrive/components/confirmdialogue.dart';
import 'package:Arrive/components/styles.dart';
import 'package:Arrive/main.dart';
import 'package:Arrive/models/geofenceRule.dart';
import 'package:Arrive/models/place.dart';
import 'package:Arrive/screens/places/addPlace.dart';
import 'package:Arrive/screens/places/placeListItem.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:Arrive/utils/constants.dart';
import 'package:Arrive/utils/geofence.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlacesScreen extends StatefulWidget {
  static const String routeName = "/places";
  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  Places places = new Places();

  @override
  void initState() {
    super.initState();
    getPlaces();
  }

  void getPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ps = prefs.getString(kPlacesStorageKey);
    String userEmail = prefs.getString(kEwelinkEmailStorage);
    setState(() {
      if (ps != null)
        places = Places.fromString(ps);
      else
        places = new Places();
      places.items = places.items.where((item) => item.userEmail == userEmail).toList();
    });
  }

  void deletePlace(Place place) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    BlurryDialog alert = BlurryDialog(
      "",
      "Are you sure you want to delete this place? This will delete actions for this place as well.",
      "Delete",
      () async {
        places.items.removeWhere((element) => element.id == place.id);
        prefs.setString(kPlacesStorageKey, places.toString());
        GeofenceRules rulesList = new GeofenceRules();
        String gs = prefs.getString(kGeofenceRulesStorageKey);
        if (gs != null) rulesList = GeofenceRules.fromString(gs);
        rulesList.rules.removeWhere((element) => element.place.id == place.id);
        await prefs.setString(kGeofenceRulesStorageKey, rulesList.toString());
        GeofenceUtilities.checkGeofenceRules();
        homeScreenKey.currentState.getSettings();
        setState(() {
          places.items = places.items;
        });
      },
    );

    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My places',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: places.items.length == 0
                      ? [
                          SizedBox(height: 10),
                          Text(
                            'You can add places of interest and add actions to them, click on the + button',
                            style: kNormalTextStyle,
                          )
                        ]
                      : places.items.map((item) => PlaceListItem(item, deletePlace, ObjectKey(item.id))).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAddButtonLightColor,
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AddPlaceScreen.routeName);
          if (result != null) getPlaces();
        },
      ),
    );
  }
}
