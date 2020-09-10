import 'package:Arrive/models/geofenceRule.dart';
import 'package:Arrive/models/place.dart';
import 'package:Arrive/models/ewelinkdevice.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:Arrive/utils/constants.dart';
import 'package:Arrive/utils/customToast.dart';
import 'package:Arrive/utils/geofence.dart';
import 'package:Arrive/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddGeofenceRuleScreen extends StatefulWidget {
  static const String routeName = "/addGeofenceRule";
  @override
  _AddGeofenceRuleScreenState createState() => _AddGeofenceRuleScreenState();
}

class _AddGeofenceRuleScreenState extends State<AddGeofenceRuleScreen> {
  final _formKey = GlobalKey<FormState>();
  Places places = new Places();
  EwelinkDevices devices = new EwelinkDevices();

  @override
  void initState() {
    super.initState();
    getPlaces();
  }

  void getPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ds = prefs.getString(kEwelinkDevicesStorage);
    String ps = prefs.getString(kPlacesStorageKey);
    String userEmail = prefs.getString(kEwelinkEmailStorage);
    setState(() {
      if (ps != null) places = Places.fromString(ps);
      if (ds != null) devices = EwelinkDevices.fromString(ds);

      places.items = places.items.where((item) => item.userEmail == userEmail).toList();
      devices.devices = devices.devices.where((item) => item.userEmail == userEmail).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Place _selectedPlace;
    EwelinkDevice _selectedDevice;
    String _selectedEvent = 'ENTER';
    String _selectedAction = "toggle";
    bool _selectedpersistAfterAction = false;

    void addGeofenceRule() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String gs = prefs.getString(kGeofenceRulesStorageKey);

      GeofenceRules rulesList = new GeofenceRules();
      if (gs != null) rulesList = GeofenceRules.fromString(gs);

      String ewelinkEmail = prefs.getString(kEwelinkEmailStorage);
      if (ewelinkEmail == null) {
        CustomToast.showError("Unexpected behaviour, not logged in to ewelink");
        return;
      }
      GeofenceRule rule = new GeofenceRule(
        makeId(),
        ewelinkEmail,
        _selectedPlace,
        _selectedDevice,
        _selectedEvent,
        _selectedAction,
        active: true,
        persistAfterAction: _selectedpersistAfterAction,
      );
      print('adding rule $rule');
      rulesList.rules.add(rule);
      prefs.setString(kGeofenceRulesStorageKey, rulesList.toString());

      await GeofenceUtilities.addGeofence(rule.place);
      CustomToast.showSuccess('Added successfully');
      Navigator.pop(context, rule);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add action",
        ),
      ),
      body: Container(
        padding: new EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Container(
                    width: 300,
                    child: Column(
                      children: [
                        DropdownSearch<Place>(
                          label: "Place",
                          items: places.items,
//                                  onFind: (String filter) => getData(filter),
                          itemAsString: (Place p) => p.name,
                          onChanged: (Place p) {
                            _selectedPlace = p;
                          },
                          validator: (Place p) {
                            if (p == null) return "Please select a place";
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        DropdownSearch<String>(
                          mode: Mode.MENU,
                          label: "Event",
                          items: ['Enter', 'Exit'],
                          selectedItem: 'Enter',
                          onChanged: (String d) {
                            switch (d) {
                              case 'Enter':
                                _selectedEvent = 'ENTER';
                                break;
                              case 'Exit':
                                _selectedEvent = 'EXIT';
                                break;
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        DropdownSearch<EwelinkDevice>(
                          label: "Device",
                          items: devices.devices,
                          itemAsString: (EwelinkDevice d) => d.name,
                          onChanged: (EwelinkDevice d) {
                            _selectedDevice = d;
                          },
                          validator: (EwelinkDevice d) {
                            if (d == null) return "Please select a device";
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        DropdownSearch<String>(
                          mode: Mode.MENU,
                          label: "Device action",
                          items: ['toggle'],
                          selectedItem: "toggle",
                          onChanged: (String d) {
                            _selectedAction = d;
                          },
                        ),
                        SizedBox(height: 20),
                        DropdownSearch<String>(
                          mode: Mode.MENU,
                          label: "Recurrence",
                          items: ['one time', 'repeating'],
                          selectedItem: "one time",
                          onChanged: (String d) {
                            switch (d) {
                              case 'one time':
                                _selectedpersistAfterAction = false;
                                break;
                              case 'repeating':
                                _selectedpersistAfterAction = true;
                                break;
                            }
                          },
                        ),
                      ],
                    ),
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
                              addGeofenceRule();
                            }
                          },
                          child: Text('Add action'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
