import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../utils/customToast.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/login";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String ewelinkEmail;
  String ewelinkPassword;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  void loginEwelink(email, password) async {
    setState(() {
      _isLoading = true;
    });
    var response = await http
        .post(kEwelinkEndpoint, body: json.encode({"ewelinkEmail": email, "ewelinkPassword": password}), headers: {"Accept": "*/*", "Content-Type": "application/json", "x-api-key": kLambdaAPIKey});
    var responseBody = json.decode(response.body);
    print("ewelink login response::: $responseBody");
    if (responseBody["result"] != true || responseBody["error"] != null || responseBody["user"] == null) {
      CustomToast.showError(responseBody["message"] ?? responseBody["msg"] ?? "Login failed");
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('ewelinkEmail', email);
      prefs.setString('ewelinkPassword', password);
      setState(() {
        ewelinkEmail = email;
        ewelinkPassword = password;
      });
      Navigator.pushReplacementNamed(
        context,
        HomeScreen.routeName,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Arrive',
                textAlign: TextAlign.center,
                style: TextStyle(
//                  fontFamily: 'Pacifico',
                  fontSize: 50,
                  color: kPrimaryColor,
                ),
              ),
              Text(
                'Home sweet home',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 30,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Text(
                'Login to ewelink',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 25,
                  color: kBoldFontColor,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    child: TextFormField(
                      decoration: InputDecoration(hintText: 'name@example.com'),
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter ewelink email';
                        }
                        Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = new RegExp(pattern);
                        if (!regex.hasMatch(value))
                          return 'Please enter a valid email';
                        else
                          return null;
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(50, 0, 50, 10),
                    child: TextFormField(
                      decoration: InputDecoration(hintText: 'password'),
                      controller: _passwordCtrl,
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter ewelink password';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(50, 0, 50, 10),
                    child: Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.teal,
                          child: Text(_isLoading ? 'Logging in' : 'Login'),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
//                                print(_emailCtrl.text);
//                                print(_passwordCtrl.text);
                              FocusScope.of(context).unfocus();
                              loginEwelink(_emailCtrl.text, _passwordCtrl.text);
                            }
                          },
                        )),
                  ),
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
