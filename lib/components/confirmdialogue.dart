import 'dart:ui';
import 'package:Arrive/utils/colors.dart';
import 'package:flutter/material.dart';

class BlurryDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final continueCallBack;

  BlurryDialog(this.title, this.content, this.confirmText, this.continueCallBack);
  TextStyle textStyle = TextStyle(color: kDangerColor);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: new Text(
            title,
            style: textStyle,
          ),
          content: new Text(
            content,
            style: textStyle,
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                confirmText,
                style: textStyle,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                continueCallBack();
              },
            ),
            new FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: kPrimaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}
