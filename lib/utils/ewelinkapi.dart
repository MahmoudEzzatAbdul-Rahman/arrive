import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'customToast.dart';

class EwelinkAPI {
  static Future<dynamic> post(event) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      String _ewelinkEmail = prefs.getString(kEwelinkEmailStorage);
      String _ewelinkPassword = prefs.getString(kEwelinkPasswordStorage);
      Map<String, dynamic> body = event;
      body["ewelinkEmail"] = body["ewelinkEmail"] ?? _ewelinkEmail;
      body["ewelinkPassword"] = body["ewelinkPassword"] ?? _ewelinkPassword;
      var response = await http.post(
        kEwelinkEndpoint,
        body: json.encode(body),
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json",
          "x-api-key": kLambdaAPIKey,
        },
      );
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        // should show an error message
        CustomToast.showError(responseBody["error"]);
        return null;
      }
    } catch (error) {
      print(error);
    }
    return null;
  }
}
