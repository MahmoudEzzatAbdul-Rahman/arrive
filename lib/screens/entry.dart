import 'package:Arrive/screens/home/home.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:Arrive/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class EntryScreen extends StatelessWidget {
  static const String routeName = "/";

  _checkForToken(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _ewelinkEmail = prefs.getString(kEwelinkPasswordStorage);
    String _ewelinkPassword = prefs.getString(kEwelinkPasswordStorage);
    if (_ewelinkEmail != null && _ewelinkPassword != null) {
      Navigator.pushReplacementNamed(
        context,
        HomeScreen.routeName,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        LoginScreen.routeName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkForToken(context);
    return Scaffold(
      body: Center(
        child: SpinKitRotatingCircle(
          color: kPrimaryColor,
          size: 48,
        ),
      ),
    );
  }
}
