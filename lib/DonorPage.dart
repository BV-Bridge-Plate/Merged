import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'DB/mongo2.dart';
import 'DB/mongodb.dart';

// Define a global variable to store the last donor ID
String lastDonorId = 'A001';

class DMenuList {
  const DMenuList(this.label, this.icon, this.selectedicon);

  final String label;
  final Widget icon;
  final Widget selectedicon;
}

const List<DMenuList> items = <DMenuList>[
  DMenuList('profile', Icon(Icons.account_circle_outlined),
      Icon(Icons.account_circle)),
  DMenuList('page 0', Icon(Icons.widgets_outlined), Icon(Icons.widgets)),
  DMenuList(
      'page 1', Icon(Icons.format_paint_outlined), Icon(Icons.format_paint)),
  DMenuList(
      'page 2', Icon(Icons.text_snippet_outlined), Icon(Icons.text_snippet)),
  DMenuList(
      'page 3', Icon(Icons.invert_colors_on_outlined), Icon(Icons.opacity)),
];

class Doner extends StatefulWidget {
  @override
  _DonerState createState() => _DonerState();
}

class _DonerState extends State<Doner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doner'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('Hello There'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ...items.map((item) {
              return ListTile(
                title: Text(item.label),
                leading: item.icon,
                onTap: () {
                  Navigator.pop(context);
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
              height: 250, // Adjust this value as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      child: Container(
                        width: 330,
                        child: Center(child: Text('Card $index')),
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

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
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
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _selectExpiryDate(context);
          },
          child: Text('Select Expiry Date'),
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
              await MongoDatabase.connect();

              Map<String, dynamic> donationData = {
                'donorId': _generateDonorId(lastDonorId), // Generate the donor ID
                'desc': _descriptionController.text,
                'qty': _quantityController.text,
                'type': _radioValue == 0 ? 'Veg' : 'Non-Veg',
                'Nuts': _toggleValue1 ? 'Yes' : 'No',
                'Vegan': _toggleValue2 ? 'Yes' : 'No',
                'expiryDate': _expiryDate?.toIso8601String(),
              };
              if (_base64Image != null) {
                donationData['photo'] = _base64Image!;
              }

              await MongoDatabase2.insertDonation(donationData);
              print('Data saved successfully');
            } catch (e) {
              print('Failed to save data: $e');
            }
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
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
