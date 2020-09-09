import 'package:Arrive/models/ewelinkdevice.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:flutter/cupertino.dart';

class DeviceListItem extends StatelessWidget {
  final EwelinkDevice device;
  DeviceListItem(this.device);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: kPrimaryColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(device.name),
                      Text('State: ${device.state}'),
//                      Text(device.online ? 'Online' : ''),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
