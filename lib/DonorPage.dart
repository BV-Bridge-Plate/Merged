import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:core';
import 'DB/mongo2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'DB/mongodb.dart';


// Define a global variable to store the last donor ID
String lastDonorId = 'A001';
LatLng? destLocation;
List<LatLng> polyLineCoordinates = [];
LocationData? currentLocation;
LatLng? sourceLocation;
String? errorMessage;

class DMenuList {
  const DMenuList(this.label, this.icon, this.selectedicon);

  final String label;
  final Widget icon;
  final Widget selectedicon;
}

DateTime now = DateTime.now();
String formattedDate = "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}";


const List<DMenuList> items = <DMenuList>[
  DMenuList('Profile', Icon(Icons.account_circle_outlined), Icon(Icons.account_circle)),
  DMenuList('Logout', Icon(Icons.logout), Icon(Icons.logout)),
];

class Doner extends StatefulWidget {
  @override
  _DonerState createState() => _DonerState();
}

class _DonerState extends State<Doner> {
  List records = [];
  bool isLoading = true;

  void getCurrentLocation() async {
    Location location = Location();
    try {
      currentLocation = await location.getLocation();
      setState(() {
        sourceLocation = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }

    location.onLocationChanged.listen((newloc) {
      setState(() {
        currentLocation = newloc;
        sourceLocation = LatLng(newloc.latitude!, newloc.longitude!);
      });
    });
  } @override
  void initState(){
    super.initState();
    getCurrentLocation();
    fetchData();
  }
  void fetchData() async {
    await MongoDatabase2.connect();
    print("Starting data fetch...");  // Added for debugging
    records = await MongoDatabase2.fetchRecordsByDonor('1');
    print("Data fetched. Refreshing UI.");  // Added for debugging
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Donor",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black), // Set icon color to black
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu), // Use the menu icon for the drawer
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('Hello There',style: TextStyle(color: Colors.white),),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
            ...items.map((item) {
              return ListTile(
                title: Text(item.label),
                leading: item.icon,
                onTap: () {
                  if (item.label == 'Logout') {
                      Navigator.pushNamedAndRemoveUntil(context, 'Donor', (route) => false);
                  } else {
                    Navigator.pop(context);  // This is for other drawer items, so it just closes the drawer.
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Form Component
            Card(
              margin:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DonationForm(),
              ),
            ),

            // Text for Previous Submits
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Text(
                "Previous Records",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Horizontal Scrolling Cards with a fixed height
            Container(
              height: 250,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())  // Shows while data is being loaded
                  : records.isEmpty
                  ? Center(child: Text('No data found'))  // In case no records are found
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: records.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      borderOnForeground: true,
                      shape: RoundedRectangleBorder(  // Adds a border to the card
                        side: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: 330,
                        child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Description: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.yellow, // You can adjust this color for the highlight effect
                                ),
                              ),
                              TextSpan(
                                text: '${records[index]['desc']}.\n\n',
                              ),
                              TextSpan(
                                text: 'Quantity: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.yellow, // You can adjust this color for the highlight effect
                                ),
                              ),
                              TextSpan(
                                text: '${records[index]['qty']}',
                              ),
                            ],
                          ),
                        )
                        ), // replace 'fieldName' with the field's name from your MongoDB document that you wish to display.
                      ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonationForm extends StatefulWidget {
  @override
  _DonationFormState createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  File? _image;
  String? _base64Image;
  int? _radioValue;
  bool _toggleValue1 = false;
  bool _toggleValue2 = false;
  DateTime? _expiryDate;
  String? lat;
  String? lan;

  Future<void> _pickImage() async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        File originalFile = File(pickedFile.path); // Convert XFile to File
        final compressedFile = await _compressImage(originalFile);
        if (compressedFile != null) {
          setState(() {
            _image = compressedFile;
            _base64Image = base64Encode(_image!.readAsBytesSync());
          });
        } else {
          print("Error: Compressed file is null");
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final uint8list = await file.readAsBytes();
      final decodedImage = img.decodeImage(uint8list);

      if (decodedImage != null) {
        final compressedUint8list =
        img.encodeJpg(decodedImage, quality: 50);
        final compressedFile =
        await File(file.path).writeAsBytes(compressedUint8list);
        return compressedFile;
      }
    } catch (e) {
      print("Error compressing image: $e");
    }
    return null;
  }

  String _generateDonorId(String previousDonorId) {
    if (previousDonorId.isEmpty) {
      return 'A001';
    }

    var number = int.tryParse(previousDonorId.substring(1)) ?? 0;
    number++;
    lastDonorId = 'A${number.toString().padLeft(3, '0')}';
    return lastDonorId;
  }

  Future<void> _selectExpiryDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _expiryDate = combinedDateTime;
        });
      }
    }
  }


  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Data have been successfully saved!'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                _descriptionController.clear();
                _quantityController.clear();
                _radioValue = null;
                _toggleValue1 = false;
                _toggleValue2 = false;
                _expiryDate = null;
                _image = null;
                _base64Image = null;

                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _descriptionController,
          minLines: 5,
          maxLines: 10,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: "Describe here the food details and also the nutritional information",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _quantityController,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        Column(
          children: <Widget>[
            ListTile(
              title: const Text('Veg'),
              leading: Radio<int>(
                value: 0,
                groupValue: _radioValue,
                onChanged: (int? value) {
                  setState(() {
                    _radioValue = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Non-Veg'),
              leading: Radio<int>(
                value: 1,
                groupValue: _radioValue,
                onChanged: (int? value) {
                  setState(() {
                    _radioValue = value;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: const Text("Nuts: Yes/No"),
          value: _toggleValue1,
          onChanged: (bool value) {
            setState(() {
              _toggleValue1 = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text("Vegan: Yes/No"),
          value: _toggleValue2,
          onChanged: (bool value) {
            setState(() {
              _toggleValue2 = value;
            });
          },
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Capture Image'),
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _selectExpiryDateTime(context);
          },
          child: Text('Select Expiry Date'),
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        SizedBox(height: 16),
        if (_expiryDate != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Expiry Date: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 18),
            ),
          ),
        if (_image != null) Image.file(_image!),
        ElevatedButton(
          onPressed: () async {
            try {

              await MongoDatabase2.connect();

              Map<String, dynamic> donationData = {
                'donorId': _generateDonorId(lastDonorId), // Generate the donor ID
                'desc': _descriptionController.text,
                'qty': _quantityController.text,
                'type': _radioValue == 0 ? 'Veg' : 'Non-Veg',
                'Nuts': _toggleValue1 ? 'Yes' : 'No',
                'Vegan': _toggleValue2 ? 'Yes' : 'No',
                'Date': formattedDate,
                'expiry': _expiryDate?.toIso8601String(),
                'latitude': currentLocation!.latitude,
                'longitude': currentLocation!.longitude,
              };
              if (_base64Image != null) {
                donationData['photo'] = _base64Image!;
              }

              await MongoDatabase2.insertDonation(donationData);
              print('Data saved successfully');
              _showSuccessDialog(context);
            } catch (e) {
              print('Failed to save data: $e');
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 16),
            ),
          ),
        )
      ],
    );
  }
}
