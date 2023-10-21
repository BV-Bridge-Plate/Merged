import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'DB/mongodb.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class DonorRegistration extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;
  String? _imageBase64;

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      await MongoDatabase.connect();
      int newUserId = await MongoDatabase.fetchLatestUserId();
      newUserId++; // Increment the ID

      var userData = {
        'id': newUserId,
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passController.text,
        'phoneno': _phoneController.text,
        'photo': _imageBase64, // Store the base64 in the user data
        // Add other user data fields as needed
      };

      await MongoDatabase.insertUser(userData);

      // Show a snackbar or navigate to a new screen on successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful!'),
        ),
      );
    }
    Navigator.pushNamed(context, 'Donorr');
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Linked to MetaMask!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


// Inside your _getImage function, update isImageSelected when an image is selected
  Future<void> _getImage(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      // Convert the selected image to base64
      List<int> imageBytes = _selectedImage!.readAsBytesSync();
      _imageBase64 = base64Encode(imageBytes);
      print(_imageBase64);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Donor Registration",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Image.file(
                      _selectedImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _getImage(context);
                  },
                  icon: Icon(Icons.upload),
                  label: Text('Upload Image'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Reuben',
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'reuben@gmail.com',
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passController,
                  validator: (value) {
                    if (value!.length <= 8) {
                      return 'Please enter a strong password';
                    }
                    return null;
                  },
                  obscureText: true, // Set this property to true to hide the password
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  validator: (value) {
                    // Simple validation: Check if the entered value is 10 digits
                    // You might want to add more comprehensive validation based on your requirements
                    if (value == null || value.length != 10) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    // You can add more conditions, e.g., checking if the value consists only of numbers
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Phone number should contain only digits';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone, // Set the keyboard type to phone
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showSuccessDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MetaMask',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 74),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
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
