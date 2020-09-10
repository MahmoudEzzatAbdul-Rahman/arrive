import 'package:Arrive/components/confirmdialogue.dart';
import 'package:Arrive/models/place.dart';
import 'package:Arrive/screens/places/addPlace.dart';
import 'package:Arrive/screens/places/placeListItem.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:Arrive/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlacesScreen extends StatefulWidget {
  static const String routeName = "/places";
  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  bool _loadingPlaces = true;
  Places places = new Places();

  @override
  void initState() {
    super.initState();
    getPlaces();
  }

  void getPlaces() async {
    setState(() {
      _loadingPlaces = true;
    });
//    print('my places ${places}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ps = prefs.getString(kPlacesStorageKey);
    String userEmail = prefs.getString(kEwelinkEmailStorage);
    if (ps != null) places = Places.fromString(ps);
    places.items = places.items.where((item) => item.userEmail == userEmail).toList();
    setState(() {
      _loadingPlaces = false;
    });
  }

  void deletePlace(Place place) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    BlurryDialog alert = BlurryDialog(
      "",
      "Are you sure you want to delete this place?",
      "Delete",
      () {
        setState(() {
          places.items.removeWhere((element) => element.id == place.id);
          prefs.setString(kPlacesStorageKey, places.toString());
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
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _loadingPlaces
                    ? CircularProgressIndicator()
                    : Column(
                        children: places.items.map((item) => PlaceListItem(item, deletePlace)).toList(),
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
          final result = await Navigator.pushNamed(context, AddPlaceScreen.routeName);
          if (result != null) getPlaces();
        },
      ),
    );
  }
}
