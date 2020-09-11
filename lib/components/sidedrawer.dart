import 'package:Arrive/screens/devices/devicesScreen.dart';
import 'package:Arrive/screens/home/home.dart';
import 'package:Arrive/screens/login.dart';
import 'package:Arrive/screens/places/placesScreen.dart';
import 'package:Arrive/utils/constants.dart';
import 'package:Arrive/utils/geofence.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.home),
                title: Text(
                  "Home",
                ),
                onTap: () {
                  Navigator.pop(context);
//                  Navigator.pushReplacementNamed(context, HomeScreen.routeName); // doesn't work well with global keys
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.bubble_chart),
                title: Text(
                  "Devices",
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, DevicesScreen.routeName);
                },
              ),
              ListTile(
                leading: Icon(Icons.map),
                title: Text(
                  "Places",
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, PlacesScreen.routeName);
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text(
                  "How to use",
                ),
                onTap: () {
//                  Navigator.pop(context);
//                  Navigator.pushNamed(context, HowToUseScreen.routeName);
                },
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                      ),
                      title: Text(
                        "Logout",
                      ),
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.remove(kEwelinkEmailStorage);
                        prefs.remove(kEwelinkPasswordStorage);
                        GeofenceUtilities.stopGeofenceService();
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
