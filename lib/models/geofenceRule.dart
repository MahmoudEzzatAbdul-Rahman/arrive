import 'dart:convert';

import 'package:Arrive/models/ewelinkdevice.dart';
import 'package:Arrive/models/place.dart';

//enum GeofenceEvent { ENTER, EXIT }

class GeofenceRule {
  String id;
  String userEmail;

  Place place;
  EwelinkDevice device;
//  List<EwelinkDevice> devices; // might support later
  String event; // ENTER, EXIT
  String action; // toggle

  bool active = true;
  bool persistAfterAction = false; // keep the rule active after it's triggered (suitable for lights, not suitable for gates)
  bool secondToggle = false;
  int secondToggleTimeout = 0;

  GeofenceRule(
    this.id,
    this.userEmail,
    this.place,
    this.device,
    this.event,
    this.action, {
    this.active = true,
    this.persistAfterAction = false,
    this.secondToggle = false,
    this.secondToggleTimeout = 0,
  });

  factory GeofenceRule.fromString(String s) => GeofenceRule.fromJson(json.decode(s));

  factory GeofenceRule.fromJson(Map<String, dynamic> json) => GeofenceRule(
        json["id"],
        json["userEmail"],
        Place.fromJson(json["place"]),
        EwelinkDevice.fromJson(json["device"]),
        json["event"],
        json["action"],
        active: json["active"] ?? false,
        persistAfterAction: json["persistAfterAction"] ?? false,
        secondToggle: json["secondToggle"] ?? false,
        secondToggleTimeout: json["secondToggleTimeout"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userEmail": userEmail,
        "place": place.toJson(),
        "device": device.toJson(),
        "active": active,
        "action": action,
        "persistAfterAction": persistAfterAction,
        "event": event,
        "secondToggle": secondToggle,
        "secondToggleTimeout": secondToggleTimeout,
      };

  String toString() => json.encode(toJson());
}

class GeofenceRules {
  List<GeofenceRule> rules = [];
  GeofenceRules({rules}) {
    this.rules = rules ?? [];
  }

  factory GeofenceRules.fromString(String s) {
    List<dynamic> x = json.decode(s);
    List<GeofenceRule> y = x.map((item) => GeofenceRule.fromJson(item)).toList();
    return GeofenceRules.fromJson(y.map((item) => item.toJson()).toList());
  }

  factory GeofenceRules.fromJson(List<Map<String, dynamic>> json) => GeofenceRules(rules: json.map((item) => GeofenceRule.fromJson(item)).toList());

  List<Map<String, dynamic>> toJson() => rules.map((item) => item.toJson()).toList();

  String toString() => json.encode(toJson());
}
