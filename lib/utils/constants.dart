import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// remote api configuration
String kEwelinkEndpoint = DotEnv().env['EwelinkEndpoint'];
String kLambdaAPIKey = DotEnv().env['LambdaAPIKey'];

// default app settings
const double kGeofenceRadius = 150;

// Shared preferences storage keys
const String kEwelinkEmailStorage = 'ewelinkEmail';
const String kEwelinkPasswordStorage = 'ewelinkPassword';
const String kEwelinkDevicesStorage = 'ewelinkDevices';
const String kPlacesStorageKey = 'places';
const String kGeofenceRulesStorageKey = 'geofenceRules';
