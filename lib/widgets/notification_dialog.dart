import 'package:cab_driver/brand_colors.dart';
import 'package:cab_driver/globalvariable.dart';
import 'package:cab_driver/helpers/helper_methods.dart';
import 'package:cab_driver/models/trip_details.dart';
import 'package:cab_driver/screens/new_trip_screen.dart';
import 'package:cab_driver/widgets/TaxiOutlineButton.dart';
import 'package:cab_driver/widgets/brand_divider.dart';
import 'package:cab_driver/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class NotificationDialog extends StatelessWidget {
  final TripDetails tripDetails;

  NotificationDialog({this.tripDetails});

  void checkAvailability(context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: 'Accepting request'));

    DatabaseReference newRiderRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/newtrip');
    newRiderRef.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);
      Navigator.pop(context);
      String thisRideId = "";
      if (snapshot.value != null) {
        thisRideId = snapshot.value.toString();
      } else {
        Toast.show("Ride is not found", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }

      if (thisRideId == tripDetails.rideId) {
        newRiderRef.set('accepted');
        HelperMethods.disableHomeTabLocationUpdates();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewTripScreen(tripDetails)),
        );
      } else if (thisRideId == 'cancelled') {
        Toast.show("Ride has been canceled", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else if (thisRideId == 'timeout') {
        Toast.show("Ride has timed out", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        Toast.show("Ride is not found", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30.0),
            Image.asset(
              'images/taxi.png',
              width: 100,
            ),
            SizedBox(height: 16.0),
            Text(
              'NEW TRIP REQUEST',
              style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),
            ),
            SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/pickicon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(height: 18.0),
                      Expanded(
                        child: Container(
                          child: Text(
                            tripDetails.pickupAddress,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/desticon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(height: 18.0),
                      Expanded(
                        child: Container(
                          child: Text(
                            tripDetails.destinationAddress,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 8.0),
            BrandDivider(),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: TaxiOutlineButton(
                        title: 'DECLINE',
                        color: BrandColors.colorPrimary,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: Container(
                      child: TaxiOutlineButton(
                        title: 'ACCEPT',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          checkAvailability(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
