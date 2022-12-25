import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/storage.dart';
import 'package:flutter_app/widgets/home.dart';
import 'package:flutter_app/widgets/login_screen.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = 'splash';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  @protected
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await isFirstRun();
    // await readToken();
  }

  isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      print('first run');
      await SecureStorage.deleteToken();
      prefs.setBool('first_run', false);
    }
  }

  // readToken() async {
  //   var token = await SecureStorage.getToken();
  //   print('STORED TOKEN');
  //   print(token);
  //   if (token != null) {
  //     Navigator.of(context).pushReplacement(
  //         PageRouteBuilder(pageBuilder: (_, __, ___) => const Home()));
  //   } else {
  //     Navigator.of(context).pushReplacement(
  //         PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginScreen()));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // getLocation();
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return const LoginScreen();
            } else {
              return const Home();
            }
          }
          return const Center(
            child: CircularProgressIndicator(
                color: Color.fromRGBO(30, 215, 96, 1)),
          );
        });
  }

  // getLocation() async {
  //   Location location = Location();

  //   bool _serviceEnabled;
  //   PermissionStatus _permissionGranted;
  //   LocationData _locationData;
  //   location.changeSettings(interval: 10000, distanceFilter: 100);

  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       return;
  //     }
  //   }

  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }

  //   _locationData = await location.getLocation();

  //   location.onLocationChanged.listen((LocationData currentLocation) {
  //     // var x = _locationData.time! - currentLocation.time!;
  //     final uid = auth.currentUser?.uid;
  //     if (currentLocation.latitude != null &&
  //         currentLocation.longitude != null &&
  //         uid != null) {
  //       var location =
  //           GeoPoint(currentLocation.latitude!, currentLocation.longitude!);
  //       FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(uid)
  //           .set({'location': location}, SetOptions(merge: true));
  //     }
  //   });
  // }
}
