import 'dart:convert';

//enum DeviceAction { toggle, turnon, turnoff }
//enum DeviceAction { toggle } // initially we'll support toggle only

class EwelinkDevice {
  String name;
  String deviceId;
  String userEmail;
  String state;
  bool online;

  EwelinkDevice(this.name, this.deviceId, this.userEmail, {this.state, this.online});

  factory EwelinkDevice.fromString(String s) => EwelinkDevice.fromJson(json.decode(s));

  factory EwelinkDevice.fromJson(Map<String, dynamic> json) => EwelinkDevice(
        json["name"],
        json["deviceid"],
        json["userEmail"],
        state: (json["params"] ?? {})["switch"],
        online: json["online"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "deviceid": deviceId,
        "userEmail": userEmail,
        "state": state,
      };

  String toString() => json.encode(toJson());
}

class EwelinkDevices {
  List<EwelinkDevice> devices = [];
  EwelinkDevices({devices}) {
    this.devices = devices ?? [];
  }

  factory EwelinkDevices.fromString(String s) {
    List<dynamic> x = json.decode(s);
    List<EwelinkDevice> y = x.map((item) => EwelinkDevice.fromJson(item)).toList();
    return EwelinkDevices.fromJson(y.map((item) => item.toJson()).toList());
  }

  factory EwelinkDevices.fromJson(List<Map<String, dynamic>> json) => EwelinkDevices(devices: json.map((item) => EwelinkDevice.fromJson(item)).toList());

  List<Map<String, dynamic>> toJson() => devices.map((item) => item.toJson()).toList();

  String toString() => json.encode(toJson());
}
