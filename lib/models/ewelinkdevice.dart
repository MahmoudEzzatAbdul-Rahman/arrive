import 'dart:convert';

//enum DeviceAction { toggle, turnon, turnoff }
enum DeviceAction { toggle } // initially we'll support toggle only

class EwelinkDevice {
  String name;
  String state;
  String deviceId;
  bool online;

  EwelinkDevice(this.name, this.deviceId, {this.state, this.online});

  factory EwelinkDevice.fromString(String s) => EwelinkDevice.fromJson(json.decode(s));

  factory EwelinkDevice.fromJson(Map<String, dynamic> json) => EwelinkDevice(
        json["name"],
        json["deviceid"],
        state: json["params"]["switch"],
        online: json["online"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "deviceId": deviceId,
        "state": state,
      };

  String toString() => json.encode(toJson());
}
