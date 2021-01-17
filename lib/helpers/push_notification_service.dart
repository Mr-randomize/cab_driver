import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cab_driver/globalvariable.dart';
import 'package:cab_driver/models/trip_details.dart';
import 'package:cab_driver/widgets/notification_dialog.dart';
import 'package:cab_driver/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging();

  Future initialize(context) async {
    if (Platform.isIOS) {
      fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message), context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message), context);
      },
      onResume: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message), context);
      },
    );
  }

  Future<String> getToken() async {
    String token = await fcm.getToken();
    print('token: $token');
    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/token');
    tokenRef.set(token);

    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');
  }

  String getRideId(Map<String, dynamic> message) {
    String rideId = '';
    if (Platform.isAndroid) {
      rideId = message['data']['ride_id'];
    } else {
      rideId = message['ride_id'];
    }
    return rideId;
  }

  void fetchRideInfo(String rideId, context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: 'Fetching details'));

    DatabaseReference rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/$rideId');

    rideRef.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);
      if (snapshot.value != null) {
        assetsAudioPlayer.open(
          Audio("sounds/alert.mp3"),
        );
        assetsAudioPlayer.play();

        double pickupLat =
            double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng =
            double.parse(snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat =
            double.parse(snapshot.value['destination']['latitude'].toString());
        double destinationLng =
            double.parse(snapshot.value['destination']['longitude'].toString());
        String destinationAddress =
            snapshot.value['destination_address'].toString();
        String paymentMethod = snapshot.value['payment_method'].toString();

        TripDetails tripDetails = TripDetails();
        tripDetails.rideId = rideId;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.pickup = LatLng(pickupLat, pickupLng);
        tripDetails.destination = LatLng(destinationLat, destinationLng);
        tripDetails.paymentMethod = paymentMethod;

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) => NotificationDialog(
            tripDetails: tripDetails,
          ),
        );
      }
    });
  }
}
