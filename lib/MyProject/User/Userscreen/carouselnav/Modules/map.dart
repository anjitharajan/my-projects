import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final String hospitalId;

  MapScreen({super.key, required this.hospitalId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _hospitalLocation = LatLng(12.9716, 77.5946);
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hospital Map")),
      body: GoogleMap(
        onMapCreated: (controller) => _controller = controller,
        initialCameraPosition: CameraPosition(
          target: _hospitalLocation,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId("hospital"),
            position: _hospitalLocation,
            infoWindow: InfoWindow(title: "Hospital Location"),
          ),
        },
      ),
    );
  }
}
