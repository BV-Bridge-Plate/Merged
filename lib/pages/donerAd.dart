import 'dart:async';

import 'package:ipfs/dbhelper/constant.dart';
import 'package:ipfs/dbhelper/mongodb.dart';
import 'package:ipfs/pages/donationCard.dart';
import 'package:ipfs/pages/qrcode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

//import 'package:web_socket_channel/web_socket_channel.dart';
class DMenuList {
  const DMenuList(this.label, this.icon, this.selectedicon);

  final String label;
  final Widget icon;
  final Widget selectedicon;
}

const List<DMenuList> items = <DMenuList>[
  DMenuList('profile', Icon(Icons.account_circle_outlined),
      Icon(Icons.account_circle)),
  DMenuList('QR-Code', Icon(Icons.widgets_outlined), Icon(Icons.widgets)),
  DMenuList(
      'page 1', Icon(Icons.format_paint_outlined), Icon(Icons.format_paint)),
  DMenuList(
      'page 2', Icon(Icons.text_snippet_outlined), Icon(Icons.text_snippet)),
  DMenuList(
      'page 3', Icon(Icons.invert_colors_on_outlined), Icon(Icons.opacity)),
];

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  List<dynamic> cards = [];
  bool isLoading = true;
  String? errorMessage;
  List<dynamic> token = [];
  @override
  void initState() {
    super.initState();
    getCurrentLocation(); // Initialize location tracking
    fetchCards();
    fetchinsentives();
  }

  Future<void> fetchCards() async {
    try {
      await MongoDatabase.connect();
      cards = await MongoDatabase.donationCollection.find().toList();
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchinsentives() async {
    try {
      await MongoDatabase.connect2();
      token = await MongoDatabase.donorCollection.find().toList();
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Future<double> getDistanceBetween(
      double lat1, double lon1, double lat2, double lon2) async {
        if (lat2 == null || lon2 == null) {
      return 0.0;
    }
    final String apiKey = MAPKEY;
    final String apiUrl = DISTURL;

    final response = await http.get(Uri.parse(
        '$apiUrl?units=imperial&origins=$lat1,$lon1&destinations=$lat2,$lon2&key=$apiKey'));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      double distanceMeters = jsonResponse['rows']?[0]['elements']?[0]
              ['distance']?['value']
          .toDouble();
      return distanceMeters;
    } else {
      throw Exception('Failed to load distance');
    }
  }

  LocationData? currentLocation;

  void getCurrentLocation() async {
    Location location = Location();
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }

   /* location.onLocationChanged.listen((newloc) {
      setState(() {
        currentLocation = newloc;
      });
    });*/
  }

  Widget displayDistance(double? lat, double? lon) {
    if (lat == null || lon == null) {
      return Text("No location data available");
    }
    if (currentLocation == null) {
      return Text("Calculating distance...");
    }

    return FutureBuilder<double>(
      future: getDistanceBetween(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
        lat,
        lon,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Calculating distance...");
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return Text("Distance: ${snapshot.data} meters");
        }
      },
    );
  }

  MemoryImage base64ToImage(String base64String) {
    Uint8List bytes = base64Decode(base64String);
    return MemoryImage(bytes);
  }
  void onDrawerItemTap(String label) {
  switch (label) {
    case 'profile':
      // Navigate to profile page or perform any other action
      break;
    case 'QR-Code':
        Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>const QRCode() ));  // Navigate to QR-Scanner page or perform any other action
      break;
    case 'page 1':
      // Navigate to page 1 or perform any other action
      break;
    case 'page 2':
      // Navigate to page 2 or perform any other action
      break;
    case 'page 3':
      // Navigate to page 3 or perform any other action
      break;
    default:
      break;
  }
}


  void showCardDialog(BuildContext context, Map<dynamic, dynamic> cardData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Card Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(image: base64ToImage(cardData['photo'])),
              SizedBox(height: 10),
              Text("Quantity: ${cardData['qty']}"),
              SizedBox(height: 10),
              Text("Description: ${cardData['desc']}"),
            ],
          ),
          actions: [
            TextButton(
              child: Text("select"),
              onPressed: () {
                try {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DonationCard(id: cardData['donerid']),
                  ));
                } catch (error) {
                  setState(() {
                    errorMessage = error.toString();
                  });
                }
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
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
    return Scaffold(
      appBar: AppBar(title: Text('Doner')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  Text('Menu'),
                  SizedBox(height: 10),
                  ...token
                      .map((t) => Text(t['incen_recv'].toString()))
                      .toList(),
                ],
              ),
            ),
            ...items.map((item) {
              return ListTile(
                title: Text(item.label),
                leading: item.icon,
                 onTap: () {
      Navigator.pop(context); // close the drawer
      onDrawerItemTap(item.label); // handle the item tap
    },
  );
}).toList(),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading:
                            Image(image: base64ToImage(cards[index]['photo'])),
                        title: Text((cards[index]['qty']).toString()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(cards[index]['desc']),
                            SizedBox(height: 10),
                            displayDistance(
                                cards[index]?["lat"] ?? 0.0,
                                cards[index]?["long"] ??
                                    0.0) //MapPage(lat: dondetails?['lat'] ?? 0.0, long: dondetails?['long'] ?? 0.0)
                          ],
                        ),

                        onTap: () => showCardDialog(
                            context, cards[index]), // <-- Add this line
                      ),
                    );
                  }),
    );
  }
}
