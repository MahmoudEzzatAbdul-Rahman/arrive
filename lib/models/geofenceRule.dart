import 'dart:convert';

import 'package:Arrive/models/ewelinkdevice.dart';
import 'package:Arrive/models/place.dart';

enum GeofenceEvent { ENTER, EXIT }

class GeofenceRule {
  String id;
  String userEmail;

  Place place;
  EwelinkDevice device;
//  List<EwelinkDevice> devices; // might support later

  bool active = true;
  bool persistAfterAction = false; // keep the rule active after it's triggered (suitable for lights, not suitable for gates)
  GeofenceEvent event;
  DeviceAction action;

  GeofenceRule(this.id, this.userEmail, this.place, this.device, this.event, this.action, {this.active, this.persistAfterAction});

  factory GeofenceRule.fromString(String s) => GeofenceRule.fromJson(json.decode(s));

  factory GeofenceRule.fromJson(Map<String, dynamic> json) => GeofenceRule(
        json["id"],
        json["userEmail"],
        json["place"],
        json["device"],
        json["event"],
        json["action"],
        active: json["active"],
        persistAfterAction: json["persistAfterAction"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userEmail": userEmail,
        "place": place.toJson(),
        "device": device.toJson(),
        "active": active,
        "persistAfterAction": persistAfterAction,
        "event": event,
        "action": action,
      };

  String toString() => json.encode(toJson());
}
