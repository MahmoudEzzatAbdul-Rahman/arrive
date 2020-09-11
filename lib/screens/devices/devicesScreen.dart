import 'package:Arrive/components/styles.dart';
import 'package:Arrive/models/ewelinkdevice.dart';
import 'package:Arrive/utils/constants.dart';
import 'package:Arrive/utils/customToast.dart';
import 'package:Arrive/utils/ewelinkapi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DeviceListItem.dart';

class DevicesScreen extends StatefulWidget {
  static const String routeName = "/devices";
  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _loadingDevices = true;
  EwelinkDevices devicesList = new EwelinkDevices();

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  void getDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ewelinkEmail = prefs.getString(kEwelinkEmailStorage);
    if (ewelinkEmail == null) {
      CustomToast.showError("Unexpected behaviour, not logged in to ewelink");
      return;
    }
    var response = await EwelinkAPI.post({'requestMethod': 'getDevices'});
//    print("ewelink get devices response::: ${response}");
    int i = 0;
    var iterator;
    while (true) {
      iterator = response[i.toString()];
      if (iterator == null) break;
      iterator["userEmail"] = ewelinkEmail;
      devicesList.devices.add(EwelinkDevice.fromJson(iterator));
      i++;
    }
    devicesList.devices = devicesList.devices.where((item) => item.online).toList();
    prefs.setString(kEwelinkDevicesStorage, devicesList.toString());
    setState(() {
      _loadingDevices = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My devices',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _loadingDevices
                    ? CircularProgressIndicator()
                    : Column(
                        children: devicesList.devices.length == 0
                            ? [
                                SizedBox(height: 10),
                                Text(
                                  'Couldn\'t find ewelink devices',
                                  style: kNormalTextStyle,
                                )
                              ]
                            : devicesList.devices.map((item) => DeviceListItem(item, ObjectKey(item.deviceId))).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
