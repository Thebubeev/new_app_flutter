import 'package:flutter/material.dart';
import 'package:new_app/models/Trip.dart';
import 'package:new_app/views/widgets/provider_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewTripBudgetView extends StatelessWidget {
  final db = Firestore.instance;

  final Trip trip;
  NewTripBudgetView({Key key, @required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Trip - Budget'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Finish"),
            Text("Location ${trip.title}"),
            Text("Start Date ${trip.startDate}"),
            Text("End Date ${trip.endDate}"),
            RaisedButton(
              child: Text("Finish"),
              onPressed: () async {
                // save data to fiebase
                final uid = await Provider.of(context).auth.getCurrentUID();
                await db
                    .collection("userData")
                    .document(uid)
                    .collection("trips")
                    .add(trip.toJson());
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        )));
  }
}
