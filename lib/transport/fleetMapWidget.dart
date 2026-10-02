import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class FleetMapPage extends StatefulWidget {
  const FleetMapPage({super.key});

  @override
  State<FleetMapPage> createState() => _FleetMapPageState();
}

class _FleetMapPageState extends State<FleetMapPage> {
  static const String apiUrl =
      "https://app.fleettrack.co.in/api/get_vehicles?"
      "token=fleettrackapi_c9nZIjOPEXNPvO6RUU4FJTygEAbXBiWY"
      "&email=fleettrackapi@gmail.com";

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    // _loadVehicles();  ❌ remove this
    _timer = Timer.periodic(const Duration(seconds: 40), (_) => _loadVehicles());

  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  BitmapDescriptor _getMarkerIcon(dynamic vehicle) {
    if (vehicle["speed"] > 0 || vehicle["vehicleStatus"] == "RUNNING") {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else if (vehicle["vehicleStatus"] == "PARKED") {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  Future<void> _loadVehicles() async {
    try {
      final res = await http.get(Uri.parse(apiUrl));

      if (res.statusCode != 200) return;

      final List data = jsonDecode(res.body);
      if (!mounted) return;

      final Set<Marker> newMarkers = {};

      for (var item in data) {
        final lat = double.tryParse(item["latitude"].toString());
        final lng = double.tryParse(item["longitude"].toString());
        if (lat == null || lng == null) continue;

        final marker = Marker(
          markerId: MarkerId(item["regNo"] ?? UniqueKey().toString()),
          position: LatLng(lat, lng),
          icon: _getMarkerIcon(item),
          infoWindow: InfoWindow(
            title: item["regNo"] ?? "Unknown Vehicle",
            snippet:
            "Status: ${item["vehicleStatus"]}\n"
                "Ignition: ${item["ignitionStatus"]}\n"
                "Speed: ${item["speed"]} km/h\n"
                "Odo: ${item["odoDistance"]?.toStringAsFixed(2)} km\n"
                "Last Update: ${item["date"]}",
          ),
        );
        newMarkers.add(marker);
      }

      setState(() {
        _markers
          ..clear()
          ..addAll(newMarkers);
      });

      // 👇 Zoom to fit all markers
      if (_markers.isNotEmpty && _mapController != null) {
        final bounds = _calculateBounds(_markers.map((m) => m.position).toList());
        _mapController!.animateCamera(
            CameraUpdate.newLatLng(_markers.first.position)

            // CameraUpdate.newLatLngBounds(bounds, 80), // padding around edges
        );
      }
    } catch (e) {
      debugPrint("Error fetching vehicles: $e");
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }


  @override
  Widget build(BuildContext context) {
    return  GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(20.5937, 78.9629), // India
          zoom: 6,
        ),
        markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
        // 👇 Once map is ready, immediately load vehicles & zoom
        _loadVehicles();
      },

    );
  }
}
