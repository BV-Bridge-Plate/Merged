import 'dart:convert';
import 'dart:typed_data';

import 'package:ipfs/dbhelper/details.dart';
import 'package:ipfs/pages/map_page.dart';
import 'package:flutter/material.dart';

class DonationCard extends StatefulWidget {
  final String id;
  DonationCard({required this.id});

  @override
  State<DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<DonationCard> {
  Map<String, dynamic>? details;
  Map<String, dynamic>? dondetails;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchdetails();
    fetchdonationdetails();
  }

  Future<void> fetchdetails() async {
    try {
      details = await DetailService.fetchDetailsByUserId(widget.id);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchdonationdetails() async {
    try {
      dondetails = await DetailService.fetchDonationDetailsByUserId(widget.id);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  TextStyle _headerStyle = TextStyle(
    color: Colors.black26,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    wordSpacing: 4.0,
    shadows: [
      Shadow(
        color: Colors.grey,
        offset: Offset(2.0, 2.0),
        blurRadius: 2.0,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(details?['userid'] ?? 'User'),
      ),
      body: Column(
        children: [
          //Text('Doner Home Page'),
          _buildSection(details?['name'], Color.fromARGB(227, 176, 223, 166),
              ElevatedButton(onPressed: () {}, child: const Text('Donate'))),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MapPage(
                      lat: dondetails?['lat'] ?? 0.0,
                      long: dondetails?['long'] ?? 0.0),
                ));
              },
              child: const Text('Map')),
          //  _buildSection('Past Donations', Color.fromARGB(97, 200, 70, 70)),
        ],
      ),
    );
  }

  Widget _buildSection(String header, Color bgColor, [Widget? child]) {
    MemoryImage base64ToImage(String base64String) {
      Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    }

    return Container(
       color: bgColor,
      margin: EdgeInsets.all(20),
      width: double.infinity,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(header, textAlign: TextAlign.left, style: _headerStyle),
          ),
          
          Container(
            margin: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height *
                (child == null ? 0.3 : 0.4),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white70,
            ),
            child: child != null ? Center(child: Column(children: [Text("description:${dondetails?['desc']}"),Text("units:${dondetails?['qty']}"),child],)) : null,
          ),
          Container(
            height: 150,
            width: 150,
            
            decoration: BoxDecoration(
                  
                //color: Colors.green, borderRadius: BorderRadius.circular(100)
                //more than 50% of width makes circle
                ),
            child: Image(image: base64ToImage(details?['photo'])),
          ),
        ],
      ),
    );
  }
}