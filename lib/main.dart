import 'package:Arrive/screens/devices/devicesScreen.dart';
import 'package:Arrive/screens/entry.dart';
import 'package:Arrive/screens/home/home.dart';
import 'package:Arrive/screens/login.dart';
import 'package:Arrive/screens/places/addPlace.dart';
import 'package:Arrive/screens/places/placesScreen.dart';
import 'package:Arrive/utils/geofence.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load('.env');
  bg.BackgroundGeolocation.registerHeadlessTask(backgroundGeofenceHeadlessTask);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrive | Home sweet home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity, primaryColor: kPrimaryColor, accentColor: kPrimaryColor),
      routes: {
        EntryScreen.routeName: (_) => EntryScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        HomeScreen.routeName: (_) => HomeScreen(),
        DevicesScreen.routeName: (_) => DevicesScreen(),
        PlacesScreen.routeName: (_) => PlacesScreen(),
        AddPlaceScreen.routeName: (_) => AddPlaceScreen(),
      },
    );
  }
}
