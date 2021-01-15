import 'package:cab_driver/brand_colors.dart';
import 'package:cab_driver/globalvariable.dart';
import 'package:cab_driver/screens/main_page.dart';
import 'package:cab_driver/widgets/TaxiOutlineButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VehicleInfoPage extends StatelessWidget {
  static const String id = 'vehicleinfo';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController carModelController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void updateProfile(context) {
    String id = currentFirebaseUser.uid;
    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/$id/vehicle_details');

    Map map = {
      'car_model': carModelController.text,
      'car_color': carColorController.text,
      'vehicle_number': vehicleNumberController.text,
    };
    driverRef.set(map);

    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Image.asset(
                'images/logo.png',
                height: 110,
                width: 110,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Enter vehicle details',
                      style: TextStyle(
                        fontFamily: 'Brand-Bold',
                        fontSize: 22.0,
                      ),
                    ),
                    SizedBox(height: 25),
                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Car model',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: carColorController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Car color',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: vehicleNumberController,
                      maxLength: 11,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'Vehicle Number',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 40),
                    TaxiOutlineButton(
                      color: BrandColors.colorGreen,
                      title: 'PROCEED',
                      onPressed: () {
                        if (carModelController.text.length < 3) {
                          showSnackBar('Please provide a valid car model');
                          return;
                        }
                        if (carColorController.text.length < 3) {
                          showSnackBar('Please provide a valid car color');
                          return;
                        }
                        if (vehicleNumberController.text.length < 3) {
                          showSnackBar('Please provide a valid vehicle number');
                          return;
                        }

                        updateProfile(context);
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
