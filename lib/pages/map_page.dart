
import 'package:ipfs/dbhelper/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  final double lat, long;
  const MapPage({required this.lat, required this.long});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? destLocation;
  List<LatLng> polyLineCoordinates = [];
  LocationData? currentLocation;
  LatLng? sourceLocation;
  String? errorMessage;

  void getCurrentLocation() async {
    Location location = Location();
    try {
      currentLocation = await location.getLocation();
      setState(() {
        sourceLocation = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
        getPolyPoints();
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
  }

  void getPolyPoints() async {
    if (sourceLocation == null || destLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        MAPKEY,  // Remember to replace with your API Key
        PointLatLng(sourceLocation!.latitude, sourceLocation!.longitude),
        PointLatLng(destLocation!.latitude, destLocation!.longitude));

    if (result.points.isNotEmpty) {
      setState(() {
        polyLineCoordinates = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    destLocation = LatLng(widget.lat, widget.long);
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: errorMessage != null
          ? Center(child: Text(errorMessage!))
          : currentLocation == null
              ? const Center(child: Text('loading'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                    zoom: 13,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: polyLineCoordinates,
                    )
                  },
                  markers: {
                    if (sourceLocation != null)
                      Marker(
                          markerId: MarkerId("source"), position: sourceLocation!),
                    if (destLocation != null)
                      Marker(
                          markerId: MarkerId("destination"), position: destLocation!),
                  },
                ),
    );
  }
}
