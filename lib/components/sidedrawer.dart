import 'dart:io';

import 'package:Arrive/screens/home.dart';
import 'package:Arrive/screens/login.dart';
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
                  Navigator.pushReplacementNamed(context, HomeScreen.routeName);
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
                        prefs.remove('ewelinkEmail');
                        prefs.remove('ewelinkPassword');
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
