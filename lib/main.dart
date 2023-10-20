
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ipfs/DoneReg.dart';
import 'package:ipfs/DoneePage.dart';
import 'package:ipfs/DonorPage.dart';
import 'package:ipfs/DonorReg.dart';
import 'package:ipfs/landing.dart';
import 'package:ipfs/new_choice.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:ipfs/phone.dart';
import 'package:ipfs/verify.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Check if the user is already authenticated
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    // If the user is authenticated, navigate directly to DonorDoneeChoice
    if (user != null) {
      runApp(MaterialApp(
        initialRoute: 'choice', // Navigate to DonorDoneeChoice
        debugShowCheckedModeBanner: false,
        routes: {
          'phone': (context) => MyPhone(),
          'verify': (context) => MyVerify(),
          'landing': (context) => LandingPage(),
          'choice': (context) => DonorDoneeChoice(),
          'Donee': (context) => DoneeRegistration(),
          'Donor': (context) => DonorRegistration(),
          'Donorr': (context) => Doner(),
          'Doneee': (context) => NextPage()
        },
      ));
    } else {
      // If the user is not authenticated, navigate to the landing page
      runApp(MaterialApp(
        initialRoute: 'landing',
        debugShowCheckedModeBanner: false,
        routes: {
          'phone': (context) => MyPhone(),
          'verify': (context) => MyVerify(),
          'landing': (context) => LandingPage(),
          'choice': (context) => DonorDoneeChoice(),
          'Donee': (context) => DoneeRegistration(),
          'Donor': (context) => DonorRegistration(),
          'Donorr': (context) => Doner(),
          'Doneee': (context) => NextPage()
        },
      ));
    }
  } catch (e) {
    print(e);
  }
}
