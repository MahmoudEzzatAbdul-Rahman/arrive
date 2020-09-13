import 'package:Arrive/components/styles.dart';
import 'package:Arrive/models/place.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlaceListItem extends StatefulWidget {
  final Place place;
  final deletePlace;
  final ObjectKey key;
  PlaceListItem(this.place, this.deletePlace, this.key);

  @override
  _PlaceListItemState createState() => _PlaceListItemState(place, deletePlace, key);
}

class _PlaceListItemState extends State<PlaceListItem> {
  final Place place;
  final deletePlace;
  final ObjectKey key;
  _PlaceListItemState(this.place, this.deletePlace, this.key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: kListItemBoxDecoration,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        place.name,
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 20,
                          color: kPrimaryColor,
                        ),
                      ),
                      Text('latitude: ${place.latitude}', style: kNormalTextStyle),
                      Text('longitude: ${place.longitude}', style: kNormalTextStyle),
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
                            textColor: kDeleteButtonColor,
                            color: kBackgroundColor,
                            child: Icon(Icons.close),
                            onPressed: () => {deletePlace(place)},
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
