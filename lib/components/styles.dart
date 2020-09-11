import 'package:Arrive/utils/colors.dart';
import 'package:flutter/cupertino.dart';

BoxDecoration kListItemBoxDecoration = BoxDecoration(
  color: kBackgroundColor,
  boxShadow: [
    BoxShadow(
      color: kPrimaryColor.withOpacity(0.3),
      offset: Offset(2, 1),
      blurRadius: 3,
      spreadRadius: 2,
    )
  ],
//  borderRadius: BorderRadius.all(
//    Radius.circular(5),
//  ),
);

TextStyle kNormalTextStyle = TextStyle(color: kBoldFontColor);
