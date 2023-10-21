import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'DB/mongo1.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class DoneeRegistration extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      await MongoDatabase1.connect();
      int newUserId = await MongoDatabase1.fetchLatestUserId();
      newUserId++; // Increment the ID
      var userData = {
        'userid': newUserId,
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passController.text,
        'phoneno': _phoneController.text
        // Add other user data fields as needed
      };

      await MongoDatabase1.insertUser(userData);

      // Show a snackbar or navigate to a new screen on successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful!'),
        ),
      );
    }
    Navigator.pushNamed(context, 'Doneee');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Donee Registration",
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
                        'Continue',
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
