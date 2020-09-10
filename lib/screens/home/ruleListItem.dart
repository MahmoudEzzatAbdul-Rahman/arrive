import 'package:Arrive/models/geofenceRule.dart';
import 'package:Arrive/models/place.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RuleListItem extends StatefulWidget {
  final GeofenceRule rule;
  final deleteRule;
  RuleListItem(this.rule, this.deleteRule);

  @override
  _RuleListItemState createState() => _RuleListItemState(rule, deleteRule);
}

class _RuleListItemState extends State<RuleListItem> {
  final GeofenceRule rule;
  final deleteRule;
  _RuleListItemState(this.rule, this.deleteRule);

  @override
  Widget build(BuildContext context) {
    TextStyle _normalStyle = TextStyle(color: kBoldFontColor);
    return Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kLightAccentColor,
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
                      Text('Place: ${rule.place.name}', style: _normalStyle),
                      Text('Geofence trigger: ${rule.event}', style: _normalStyle),
                      Text('Device: ${rule.device.name}', style: _normalStyle),
                      Text('Action: ${rule.action}', style: _normalStyle),
                      Text('Status: ${rule.active ? 'active' : 'inactive'}', style: _normalStyle),
                      Text('Recurrence: ${rule.persistAfterAction ? 'repeating' : 'one time'}', style: _normalStyle),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          child: RaisedButton(
                            textColor: kDangerColor,
                            color: kLightAccentColor,
                            child: Icon(Icons.delete),
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
