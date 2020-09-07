import 'package:flutter_dotenv/flutter_dotenv.dart';

String kGarageGateDeviceId = DotEnv().env['GarageGateDeviceId'];
String kGarageLightsDeviceId = DotEnv().env['GarageLightsDeviceId'];
String kEwelinkEndpoint = DotEnv().env['EwelinkEndpoint'];
String kEwelinkVerifier = DotEnv().env['EwelinkVerifier'];

const double kGeofenceRadius = 150;
String kHomeLocationId = DotEnv().env['HomeLocationId'];
double kHomeLatitude = double.parse(DotEnv().env['HomeLatitude']);
double kHomeLongitude = double.parse(DotEnv().env['HomeLongitude']);
