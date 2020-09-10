import 'package:Arrive/models/place.dart';
import 'package:Arrive/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlaceListItem extends StatefulWidget {
  final Place place;
  final deletePlace;
  PlaceListItem(this.place, this.deletePlace);

  @override
  _PlaceListItemState createState() => _PlaceListItemState(place, deletePlace);
}

class _PlaceListItemState extends State<PlaceListItem> {
  final Place place;
  final deletePlace;
  _PlaceListItemState(this.place, this.deletePlace);

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        place.name,
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 20,
                          color: kBoldFontColor,
                        ),
                      ),
                      Text('latitude: ${place.latitude}',
                          style: TextStyle(
                            color: kBoldFontColor,
                          )),
                      Text('longitude: ${place.longitude}',
                          style: TextStyle(
                            color: kBoldFontColor,
                          )),
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
