import 'dart:async';

import 'package:ipfs/dbhelper/constant.dart';
import 'package:ipfs/dbhelper/mongodb.dart';
import 'package:ipfs/pages/donationCard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import '../dbhelper/constant.dart';
import 'donationCard.dart';
import 'qrcode.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
      'Logout', Icon(Icons.logout), Icon(Icons.logout)),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? placeName;
  bool _isCardsFetched = false;
  bool _isIncentivesFetched = false;
  bool _isLocationFetched = false;
  bool _isPlaceNameFetched = false;

  @override
  void initState() {
    super.initState();
    if (!_isLocationFetched) {
      getCurrentLocation();
      _isLocationFetched = true;
    }
    if (!_isCardsFetched) {
      fetchCards();
      _isCardsFetched = true;
    }
    if (!_isIncentivesFetched) {
      fetchinsentives();
      _isIncentivesFetched = true;
    }
    if (!_isPlaceNameFetched) {
      fetchPlaceName();
      _isPlaceNameFetched = true;
    }
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

  Future<String?> getPlaceName(double lat, double lng) async {
    final String baseUrl = "https://maps.googleapis.com/maps/api/geocode/json";
    final String apiKey = MAPKEY;

    final String url = "$baseUrl?latlng=$lat,$lng&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      // Check if the response contains results
      if (jsonResponse['results'] != null &&
          jsonResponse['results'].length > 0) {
        // We're taking the formatted address of the first result here.
        // You might want to access other parts of the result, depending on your needs.
        return jsonResponse['results'][0]['formatted_address'];
      }
    } else {
      throw Exception('Failed to load location name');
    }
  }

  static Future<double> getDistanceBetween(double lat1, double lon1, double lat2, double lon2) async {
    if (lat2 == Null || lon2 == Null) {
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

  void fetchPlaceName() async {
    if (!_isPlaceNameFetched) {
      if (currentLocation != null) {
        String? fetchedPlaceName = await getPlaceName(
            currentLocation?.latitude ?? 0.0, currentLocation?.longitude ?? 0.0);
        if (fetchedPlaceName != null) {
          setState(() {
            placeName = fetchedPlaceName; // Assuming placeName is a state variable
          });
          print(placeName);
          _isPlaceNameFetched = true;
        } else {
          print('Failed to fetch place name');
        }
      } else {
        print('Current location is null');
      }
    }
  }

  void getCurrentLocation() async {
    Location location = Location();
    try {
      currentLocation = await location.getLocation();
      fetchPlaceName();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
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

  static MemoryImage base64ToImage(String base64String) {
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
            builder: (context) =>
            const QRCode())); // Navigate to QR-Scanner page or perform any other action
        break;
      case 'Logout':
      // Navigate to page 1 or perform any other action
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
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) =>
                  //       DonationCard(id: cardData['donerid']!),
                  // ));
                  Navigator.pushNamed(context, 'food');
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

      backgroundColor: Color.fromRGBO(11, 18, 46, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(11, 18, 46, 1),
        title: Text(
          placeName ?? "Fetching Location...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          // <-- Here's the change
          icon: SvgPicture.asset(
            'assets/b.svg',
            width: 60.0, // You can adjust the size if needed
            height: 60.0,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        toolbarHeight: 150,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color:  Color.fromRGBO(11, 18, 46, 1),
              ),
              child: Column(

                children: [
                  Text('Welcome, user', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
                  SizedBox(height: 10),
                  ...token
                      .map((t) => Text(t['incen_recv'].toString(),style: TextStyle(color: Colors.white, fontSize: 10),))
                      .toList(),
                ],
              ),
            ),
            ...items.map((item) {
              return Card(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                color :Color.fromRGBO(251, 254, 234, 1),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blueGrey, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child :ListTile(
                  title: Text(item.label),
                  leading: item.icon,
                  onTap: () {
                    Navigator.pop(context); // close the drawer
                    onDrawerItemTap(item.label); // handle the item tap
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: isLoading
            ? Center(
          child: SpinKitDancingSquare(
            color: Color.fromRGBO(198, 238, 231, 1),
            size: 100.0,
          ),
        )
            : errorMessage != null
            ? Center(

            child: Text(errorMessage!))
            : ListView.builder(

            itemCount: cards.length,
            itemBuilder: (context, index) {
              return Card(
                color :Color.fromRGBO(251, 254, 234, 1),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blueGrey, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(

                  contentPadding: EdgeInsets.all(5.0),
                  onTap: () => showCardDialog(context, cards[index]),
                  title: Column(
                    children: [
                      AspectRatio(
                        aspectRatio:
                        16 / 9, // or any aspect ratio you need
                        child: Image(
                            image:
                            base64ToImage(cards[index]["photo"])),
                      ),
                      SizedBox(height: 10),
                      Text('Quantity: ${cards[index]['qty'].toString()}'),
                      SizedBox(height: 10),
                      Text('Description: ${cards[index]['desc']}',textAlign: TextAlign.center,),
                      SizedBox(height: 10),
                      displayDistance(
                        cards[index]?["lat"] ?? 0.0,
                        cards[index]?["long"] ?? 0.0,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}