import 'package:cab_driver/models/trip_details.dart';
import 'package:flutter/material.dart';

class NewTripScreen extends StatefulWidget {
  final TripDetails tripDetails;

  NewTripScreen(this.tripDetails);

  @override
  _NewTripScreenState createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Trip'),
      ),
    );
  }
}
