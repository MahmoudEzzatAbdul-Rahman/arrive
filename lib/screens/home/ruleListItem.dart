import 'package:Arrive/components/styles.dart';
import 'package:Arrive/models/geofenceRule.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class RuleListItem extends StatefulWidget {
  final GeofenceRule rule;
  final deleteRule;
  final editRule;
  final ObjectKey key;
  RuleListItem(this.rule, this.editRule, this.deleteRule, this.key);

  @override
  _RuleListItemState createState() => _RuleListItemState(rule, editRule, deleteRule, key);
}

class _RuleListItemState extends State<RuleListItem> {
  final GeofenceRule rule;
  final deleteRule;
  final editRule;
  final ObjectKey key;
  _RuleListItemState(this.rule, this.editRule, this.deleteRule, this.key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: kListItemBoxDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Place: ${rule.place.name}', style: kNormalTextStyle),
                      Text(
                          'Event: ${rule.event == "ENTER" ? "Enter" : rule.event == "EXIT" ? "Exit" : ""}',
                          style: kNormalTextStyle),
                      Text('Device: ${rule.device.name}', style: kNormalTextStyle),
                      Text('Action: ${rule.action}', style: kNormalTextStyle),
                      Row(
                        children: [
                          Text('Status: ${rule.active ? 'active' : 'inactive'}', style: kNormalTextStyle),
                          Switch(
                            value: rule.active,
                            activeTrackColor: kAddButtonLightColor,
                            activeColor: kAddButtonDarkColor,
                            onChanged: (val) async {
                              if (val) {
                                var localAuth = LocalAuthentication();
                                bool didAuthenticate = await localAuth.authenticateWithBiometrics(localizedReason: 'Please authenticate to enable');
                                if (!didAuthenticate) return;
                              }
                              setState(() {
                                rule.active = val;
                                if (!val) {
                                  rule.persistAfterAction = val;
                                  rule.secondToggle = val;
                                }
                                editRule(rule);
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Recurrence: ${rule.persistAfterAction ? 'repeating' : 'one time'}', style: kNormalTextStyle),
                          Switch(
                            value: rule.persistAfterAction,
                            activeTrackColor: kAddButtonLightColor,
                            activeColor: kAddButtonDarkColor,
                            onChanged: (val) async {
                              if (val) {
                                var localAuth = LocalAuthentication();
                                bool didAuthenticate = await localAuth.authenticateWithBiometrics(localizedReason: 'Please authenticate to enable');
                                if (!didAuthenticate) return;
                              }
                              setState(() {
                                rule.persistAfterAction = val;
                                if (val) rule.active = val;
                                editRule(rule);
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Re-do action after a delay: ${rule.secondToggle ? 'yes' : 'no'}', style: kNormalTextStyle),
                          Switch(
                            value: rule.secondToggle,
                            activeTrackColor: kAddButtonLightColor,
                            activeColor: kAddButtonDarkColor,
                            onChanged: (val) async {
                              if (val) {
                                var localAuth = LocalAuthentication();
                                bool didAuthenticate = await localAuth.authenticateWithBiometrics(localizedReason: 'Please authenticate to enable');
                                if (!didAuthenticate) return;
                              }
                              setState(() {
                                rule.secondToggle = val;
                                if (val) rule.active = val;
                                editRule(rule);
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Delay in seconds:   ', style: kNormalTextStyle),
                          Container(
                              width: 50,
                              child: TextFormField(
//                                controller: _controller,
                                decoration: InputDecoration(hintText: ''),
                                keyboardType: TextInputType.number,
                                initialValue: rule.secondToggleTimeout.toString(),
                                inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                                onChanged: (val) async {
                                  setState(() {
                                    rule.secondToggleTimeout = int.parse(val);
                                    if (int.parse(val) > 0) {
                                      rule.secondToggle = true;
                                    }
                                    editRule(rule);
                                  });
                                },
                              )),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 60,
                          child: RaisedButton(
                            textColor: kDeleteButtonColor,
                            color: kBackgroundColor,
                            child: Icon(Icons.close),
                            onPressed: () => {deleteRule(rule)},
                          ),
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
