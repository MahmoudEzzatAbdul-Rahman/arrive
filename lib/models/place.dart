import 'dart:convert';

class Place {
  String id;
  String userEmail;
  String name;
  double latitude;
  double longitude;
  Place(this.id, this.userEmail, this.name, this.latitude, this.longitude);

  factory Place.fromString(String s) => Place.fromJson(json.decode(s));

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        json["id"],
        json["userEmail"],
        json["name"],
        json["latitude"],
        json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userEmail": userEmail,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
      };

  String toString() => json.encode(toJson());
}

class Places {
  List<Place> items = [];
  Places({items}) {
    this.items = items ?? [];
  }

  factory Places.fromString(String s) {
    List<dynamic> x = json.decode(s);
    List<Place> y = x.map((item) => Place.fromJson(item)).toList();
    return Places.fromJson(y.map((item) => item.toJson()).toList());
  }

  factory Places.fromJson(List<Map<String, dynamic>> json) => Places(items: json.map((item) => Place.fromJson(item)).toList());

  List<Map<String, dynamic>> toJson() => items.map((item) => item.toJson()).toList();

  String toString() => json.encode(toJson());
}
