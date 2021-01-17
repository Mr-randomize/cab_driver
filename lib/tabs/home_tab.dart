import 'dart:async';

import 'package:cab_driver/brand_colors.dart';
import 'package:cab_driver/globalvariable.dart';
import 'package:cab_driver/helpers/push_notification_service.dart';
import 'package:cab_driver/widgets/AvailabilityButton.dart';
import 'package:cab_driver/widgets/confirm_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GoogleMapController mapController;

  Completer<GoogleMapController> _controller = Completer();
  Position currentPosition;

  String availabilityTitle = 'GO ONLINE';
  Color availabilityColor = BrandColors.colorOrange;
  bool isAvailable = false;

  void getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(CameraUpdate.newLatLng(pos));
  }

  void goOnline() async {
    Geofire.initialize('driversAvailable');
    bool response = await Geofire.setLocation(currentFirebaseUser.uid,
        currentPosition.latitude, currentPosition.longitude);
    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/newtrip');
    tripRequestRef.set('waiting');

    tripRequestRef.onValue.listen((event) {});
  }

  void goOffline() {
    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;
  }

  void getLocationUpdates() {
    homeTabPositionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 4)
        .listen((Position position) {
      currentPosition = position;
      if (isAvailable) {
        Geofire.setLocation(
            currentFirebaseUser.uid, position.latitude, position.longitude);
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }

  void getCurrentDriverInfo() async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
  }

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;
            getCurrentPosition();
          },
        ),
        Container(
          height: 135,
          width: double.infinity,
          color: BrandColors.colorPrimary,
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) => ConfirmSheet(
                      title: !isAvailable ? 'GO ONLINE' : 'GO OFFLINE',
                      subtitle: isAvailable
                          ? 'You will stop receiving new trip requests.'
                          : 'You are about to become available to receive trip requests',
                      onPressed: () {
                        if (!isAvailable) {
                          goOnline();
                          getLocationUpdates();
                          Navigator.pop(context);
                          setState(() {
                            availabilityTitle = 'GO OFFLINE';
                            availabilityColor = BrandColors.colorGreen;
                            isAvailable = true;
                          });
                        } else {
                          goOffline();
                          Navigator.pop(context);
                          setState(() {
                            availabilityTitle = 'GO ONLINE';
                            availabilityColor = BrandColors.colorOrange;
                            isAvailable = false;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
