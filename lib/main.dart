import 'dart:io';

import 'package:cab_driver/globalvariable.dart';
import 'package:cab_driver/screens/login_page.dart';
import 'package:cab_driver/screens/main_page.dart';
import 'package:cab_driver/screens/registration_page.dart';
import 'package:cab_driver/screens/vehicle_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
            googleAppID: '1:194165936582:ios:ba23b9f18bd3dad39062c7',
            gcmSenderID: '194165936582',
            databaseURL: 'https://gotaxi-b26f6-default-rtdb.firebaseio.com',
          )
        : FirebaseOptions(
            googleAppID: '1:194165936582:android:8f204d7b7098e2829062c7',
            apiKey: 'AIzaSyBaIAVDQIxwkbGyaOVUC1-SzE8s1Vd-F_w',
            databaseURL: 'https://gotaxi-b26f6-default-rtdb.firebaseio.com',
          ),
  );
  currentFirebaseUser = await FirebaseAuth.instance.currentUser();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Brand-Regular',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
      routes: {
        MainPage.id: (context) => MainPage(),
        RegistrationPage.id: (context) => RegistrationPage(),
        LoginPage.id: (context) => LoginPage(),
        VehicleInfoPage.id: (context) => VehicleInfoPage(),
      },
    );
  }
}
