import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bridging hearts,\nFilling plates',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 220),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    primary: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, "phone", (route) => false);
                  },
                  child: const Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Sign in to your \nBirdgePlate Account',
                          style: TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,  // Use ellipsis for overflowed texts
                        ),
                      ),
                      SizedBox(width: 80),  // Some space between text and icon
                      Icon(Icons.arrow_forward, color: Colors.black),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
