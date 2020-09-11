import 'dart:async';

import 'package:Arrive/models/place.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:Arrive/utils/constants.dart';
import 'package:Arrive/utils/customToast.dart';
import 'package:Arrive/utils/geofence.dart';
import 'package:Arrive/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:shared_preferences/shared_preferences.dart';

class AddPlaceScreen extends StatefulWidget {
  static const String routeName = "/addPlace";

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(52.854988, -1.660440),
    zoom: 8,
  );
  LatLng _lastTap;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  final _locnameCtrl = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _locnameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void addPlace() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String ps = prefs.getString(kPlacesStorageKey);
      Places places = new Places();
      if (ps != null) places = Places.fromString(ps);

      String ewelinkEmail = prefs.getString(kEwelinkEmailStorage);
      if (ewelinkEmail == null) {
        CustomToast.showError("Unexpected behaviour, not logged in to ewelink");
        return;
      }
      Place place = new Place(makeId(), ewelinkEmail, _locnameCtrl.text, _lastTap.latitude, _lastTap.longitude);
      places.items.add(place);
      prefs.setString(kPlacesStorageKey, places.toString());

//      await GeofenceUtilities.addGeofence(place); // do this on adding a geofence rule instead
      CustomToast.showSuccess('Added successfully');
      Navigator.pop(context, place);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add place",
        ),
      ),
      body: Container(
        padding: new EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    height: 250,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        mapController = controller;
                      },
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      markers: Set<Marker>.of(markers.values),
                      onTap: (LatLng pos) {
                        var mid = MarkerId('userinput');
                        Marker marker = Marker(
                          markerId: mid,
                          position: pos,
                          onTap: () {},
                        );
                        setState(() {
                          _lastTap = pos;
                          markers[mid] = marker;
                        });
                      },
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Place name',
                        ),
                        controller: _locnameCtrl,
                        validator: (value) {
                          if (_lastTap == null) {
                            return 'Please tap a place on the map';
                          } else if (value.isEmpty) {
                            return 'Please enter place name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 60,
                      child: RaisedButton(
                        child: Icon(Icons.gps_fixed),
                        color: kBackgroundColor,
                        textColor: kBoldFontColor,
                        onPressed: () async {
                          print('getting current location');
                          bg.Location _locationData = await GeofenceUtilities.getCurrentLocation();
                          print('Current location is $_locationData');
                          var mid = MarkerId('userinput');
                          Marker marker = Marker(
                            markerId: mid,
                            position: LatLng(_locationData.coords.latitude, _locationData.coords.longitude),
                            //                    infoWindow: InfoWindow(title: 'some title', snippet: '*'),
                            onTap: () {
                              //      _onMarkerTapped(markerId);
                            },
                          );
                          setState(() {
                            _lastTap = LatLng(_locationData.coords.latitude, _locationData.coords.longitude);
                            markers[mid] = marker;
                          });
                          mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                            target: LatLng(_locationData.coords.latitude, _locationData.coords.longitude),
                            zoom: 15.0,
                          )));
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        color: kPrimaryColor,
                        textColor: kButtonTextColor,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            addPlace();
                          }
                        },
                        child: Text('Add place'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
