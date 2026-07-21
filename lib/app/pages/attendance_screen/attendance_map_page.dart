import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AttendanceMapPage extends StatelessWidget {
  final double startLat;
  final double startLng;
  final double? endLat;
  final double? endLng;

  const AttendanceMapPage({
    super.key,
    required this.startLat,
    required this.startLng,
    this.endLat,
    this.endLng,
  });

  @override
  Widget build(BuildContext context) {
    final startPoint = LatLng(startLat, startLng);
    final hasEndPoint =
        endLat != null &&
        endLng != null &&
        (startLat != endLat || startLng != endLng);
    final endPoint = hasEndPoint ? LatLng(endLat!, endLng!) : null;

    final markers = [
      Marker(
        point: startPoint,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.green, size: 40),
      ),
      if (endPoint != null)
        Marker(
          point: endPoint,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
    ];

    final polylines = [
      if (endPoint != null)
        Polyline(
          points: [startPoint, endPoint],
          color: Colors.blueAccent,
          strokeWidth: 4.0,
        ),
    ];

    final center = endPoint != null
        ? LatLng(
            (startPoint.latitude + endPoint.latitude) / 2,
            (startPoint.longitude + endPoint.longitude) / 2,
          )
        : startPoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Location Map'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: center, initialZoom: 15.0),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.agro.app',
          ),
          if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
