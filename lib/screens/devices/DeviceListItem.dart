import 'package:Arrive/components/styles.dart';
import 'package:Arrive/models/ewelinkdevice.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:Arrive/utils/ewelinkapi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceListItem extends StatefulWidget {
  final EwelinkDevice device;
  final ObjectKey key;
  DeviceListItem(this.device, this.key);

  @override
  _DeviceListItemState createState() => _DeviceListItemState(device, key);
}

class _DeviceListItemState extends State<DeviceListItem> {
  final EwelinkDevice device;
  final ObjectKey key;
  _DeviceListItemState(this.device, this.key);
  bool _changingDeviceState = false;

  void toggleDevice() async {
    setState(() {
      _changingDeviceState = true;
    });
    var res = await EwelinkAPI.post({
      'requestMethod': 'toggleDevice',
      "deviceId": device.deviceId,
    });
    print("toggle response::: $res");
    if (res["result"] == true && res["status"] == 'ok') {
      // success
      device.state = device.state == 'on' ? 'off' : 'on';
    }
    setState(() {
      _changingDeviceState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: kListItemBoxDecoration,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.device.name,
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 20,
                          color: kPrimaryColor,
                        ),
                      ),
//                      Text('State: ${widget.device.state}'),
//                      Text(device.online ? 'Online' : ''),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _changingDeviceState
                            ? CircularProgressIndicator()
                            : Switch(
                                value: widget.device.state == "on",
                                activeTrackColor: kAddButtonLightColor,
                                activeColor: kAddButtonDarkColor,
                                onChanged: (val) {
                                  toggleDevice();
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
