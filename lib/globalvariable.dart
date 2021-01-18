import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cab_driver/models/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String mapKey = 'AIzaSyBaIAVDQIxwkbGyaOVUC1-SzE8s1Vd-F_w';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);
FirebaseUser currentFirebaseUser;
DatabaseReference tripRequestRef;
DatabaseReference rideRef;
StreamSubscription<Position> homeTabPositionStream;
final assetsAudioPlayer = AssetsAudioPlayer();
Position currentPosition;
Driver currentDriverInfo;
