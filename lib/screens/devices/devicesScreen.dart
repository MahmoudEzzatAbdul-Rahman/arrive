import 'package:Arrive/models/ewelinkdevice.dart';
import 'package:Arrive/utils/ewelinkapi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'DeviceListItem.dart';

class DevicesScreen extends StatefulWidget {
  static const String routeName = "/devices";
  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _loadingDevices = true;
  List<EwelinkDevice> deviceList = [];

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  void getDevices() async {
    deviceList = [];
    var response = await EwelinkAPI.post({'requestMethod': 'getDevices'});
//    print("ewelink get devices response::: ${response}");
    int i = 0;
    var iterator;
    while (true) {
      iterator = response[i.toString()];
      if (iterator == null) break;
      deviceList.add(EwelinkDevice.fromJson(iterator));
      i++;
    }
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
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _loadingDevices
                    ? CircularProgressIndicator()
                    : Column(
                        children: deviceList.where((item) => item.online).map((item) => DeviceListItem(item)).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
