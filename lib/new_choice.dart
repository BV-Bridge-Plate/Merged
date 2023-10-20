import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'DoneReg.dart';
import 'DonorReg.dart';

class DonorDoneeChoice extends StatefulWidget {
  @override
  _DonorDoneeChoiceState createState() => _DonorDoneeChoiceState();
}

class _DonorDoneeChoiceState extends State<DonorDoneeChoice> {
  bool isDonor = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Set the background color to transparent
        elevation: 0, // Remove the shadow
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu, // Use the menu icon
                color: Colors.black, // Set the color to black
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
        // Add other AppBar properties as needed
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue, // Customize the header color as needed
              ),
              child: Text(
                'Your App Name',
                style: TextStyle(
                  color: Colors.white, // Customize the text color as needed
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout), // Add the logout icon
              title: Text('Logout'),
              onTap: () async {
                // Perform Firebase logout here
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil('landing', (Route<dynamic> route) => false); // Navigate to the landing page and remove all previous routes
                } catch (e) {
                  print("Error logging out: $e");
                }
              },
            ),
            // Add other drawer items as needed
          ],
        ),
      ),

      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Would you like to be a donor or would you like to be a donee?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              ToggleButtons(
                borderColor: Colors.black,
                fillColor: Colors.grey[300],
                selectedColor: Colors.white,
                selectedBorderColor: Colors.black,
                borderWidth: 2,
                borderRadius: BorderRadius.circular(8),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Donor', style: TextStyle(fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Donee', style: TextStyle(fontSize: 18)),
                  ),
                ],
                isSelected: isDonor ? [true, false] : [false, true],
                onPressed: (int index) {
                  setState(() {
                    isDonor = !isDonor;
                  });
                },
              ),
              SizedBox(height: 80),
              ElevatedButton(
                onPressed: () {
                  if (isDonor) {
                    Navigator.pushNamed(context, "Donor");
                  } else {
                    Navigator.pushNamed(context, "Donee");
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 74),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // This will make the row's width to be as small as possible to wrap its children
                  children: [
                    Text('Continue', style: TextStyle(color: Colors.black),),
                    SizedBox(width: 10), // Gap between text and icon
                    Icon(Icons.arrow_forward, color: Colors.black,),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
