import 'dart:convert';

class Place {
  String id;
  String name;
  double latitude;
  double longitude;
  Place(this.id, this.name, this.latitude, this.longitude);
  factory Place.fromJson(Map<String, dynamic> json) => Place(
        json["id"],
        json["name"],
        json["latitude"],
        json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
      };

  String toString() => json.encode(toJson());
}

class Places {
  List<Place> items = [];
  Places({this.items});
  factory Places.fromJson(List<Map<String, dynamic>> json) => Places(
        items: json.map((item) => Place.fromJson(item)),
      );

  List<Map<String, dynamic>> toJson() => items.map((item) => item.toJson());

  String toString() => json.encode(toJson());
}
