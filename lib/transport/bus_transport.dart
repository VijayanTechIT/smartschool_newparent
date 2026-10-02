import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_school_parent/utilis/loader.dart';
import '../student/StudentModel.dart';
import 'bus_event.dart';
import 'bus_state.dart';
import 'bus_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/bus_master_model.dart';

class BusTransportScreen extends StatefulWidget {
  const BusTransportScreen({super.key, required this.student});

  final StudentWhole student;

  @override
  State<BusTransportScreen> createState() => _BusTransportScreenState();
}

class _BusTransportScreenState extends State<BusTransportScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Timer? _timer;

  BusMaster? bus;
  String? _mapError;

  @override
  void initState() {
    super.initState();

    if (widget.student.transport != '') {
      final busBloc = context.read<BusBloc>();

      // Declare subscription first
      late final StreamSubscription<BusState> subscription;

      // Assign subscription
      subscription = busBloc.stream.listen((state) async {
        if (state is BusLoaded) {
          bus = state.bus;

          // Save the bus register number for filtering vehicles
          final String busRegNo = state.bus.busRegisterNumber;

          // Fetch vehicles filtered by this bus
          await _loadVehicles(filterRegNo: busRegNo);

          // Start periodic refresh
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
            await _loadVehicles(filterRegNo: busRegNo);
          });

          // Cancel subscription after first use
          subscription.cancel();
        }
      });

      final transport = widget.student.transport;

// ✅ Safe condition to avoid FormatException
      if (transport != null &&
          transport.isNotEmpty &&
          transport.toLowerCase() != 'null' &&
          int.tryParse(transport) != null) {
        // Trigger Bloc to fetch bus details
        busBloc.add(
          FetchBusById(
            widget.student.schoolCode,
            int.parse(transport),
          ),
        );
      }
    }
  }



  // @override
  // void initState() {
  //   super.initState();
  //
  //   if (widget.student.transport != '') {
  //     context.read<BusBloc>().add(
  //       FetchBusById(
  //         widget.student.schoolCode,
  //         int.parse(widget.student.transport),
  //       ),
  //     );
  //   }
  //
  //
  //
  //
  // }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<BitmapDescriptor> getResizedBusIcon(String path, int width) async {
    final ByteData data = await rootBundle.load(path);

    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );

    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? bytes =
    await fi.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
  Set<Marker> newMarkers = {};
  Future<void> _loadVehicles({required String filterRegNo}) async {
    print("Bus Reg Number: ${filterRegNo}");
    if (bus == null) return;

    try {
      final res = await http.get(Uri.parse(bus!.gpsLocation));




      if (res.statusCode != 200) return;

      print("Bus Response: ${res.body}");

      final decoded = jsonDecode(res.body);

      if (decoded is List) {

          newMarkers = {};
        // Normalize the filter reg no for comparison
        final normalizedFilter = filterRegNo.replaceAll(" ", "").toUpperCase();

        for (var item in decoded) {
          final regNoFull = (item["regNo"]?.toString() ?? "")
              .replaceAll(" ", "")
              .toUpperCase();

// Take only the part before "/"
          final regNo = regNoFull.split("/").first.trim();


          // Only continue if regNo matches filter
          if (regNo != normalizedFilter) continue;

          final lat = double.tryParse(item["latitude"].toString());
          final lng = double.tryParse(item["longitude"].toString());
          if (lat == null || lng == null) continue;
          String status = (item["vehicleStatus"]?.toString() ?? "").toLowerCase();
          String iconPath;
          if (status.contains("moving")) {
            iconPath = "images/bus_green.png";
          } else if (status.contains("parked")) {
            iconPath = "images/bus_orange.png";
          } else {
            iconPath = "images/bus.png"; // off/other
          }

          final busIcon = await getResizedBusIcon(
            iconPath,
            50,
          );

          final marker = Marker(
            markerId: MarkerId(item["regNo"] ?? UniqueKey().toString()),
            position: LatLng(lat, lng),
            icon: busIcon,
            infoWindow: InfoWindow(
              title: item["regNo"] ?? "Unknown Vehicle",
              snippet: "Status: ${item["vehicleStatus"]}\n"
                  "Ignition: ${item["ignitionStatus"]}\n"
                  "Speed: ${item["speed"]} km/h\n"
                  "Odo: ${item["odoDistance"]?.toStringAsFixed(2)} km\n"
                  "Last Update: ${item["date"]}",
            ),
          );
          newMarkers.add(marker);
        }

        if (!mounted) return;
          setState(() {
            if (newMarkers.isEmpty) {
              _mapError = "No matching bus found";
            } else {
              _mapError = null;

              // Keep old markers, update only those that match
              for (var newMarker in newMarkers) {
                _markers.removeWhere((m) => m.markerId == newMarker.markerId);
                _markers.add(newMarker);
              }
            }
          });


          if (_markers.isNotEmpty && _mapController != null) {
          final markerPos = _markers.first.position;
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: markerPos,
                zoom: 16, // 👈 adjust zoom level as needed (14–18 works well for streets)
              ),
            ),
          );
        }
      } else if (decoded is Map<String, dynamic> &&
          decoded.containsKey("response")) {
        final errorMsg = decoded["message"] ?? "Unknown API error";
        if (!mounted) return;
        setState(() {
          _mapError = errorMsg;

        });
      } else {
        if (!mounted) return;
        setState(() {
          _mapError = "Unexpected response format";

        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mapError = "Failed to load vehicles. Please try again.";

      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2d4c9c),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
        ),
        title: const Text('Transport'),
        centerTitle: true,
        titleTextStyle: const TextStyle(fontSize: 20.0),
      ),
      body: BlocListener<BusBloc, BusState>(
        listener: (context, state) {
          print("Bus Stater : ${state}");
          if (state is BusLoaded) {
            bus = state.bus;
            _loadVehicles(filterRegNo: state.bus.busRegisterNumber);
            _timer?.cancel();
            _timer = Timer.periodic(
              const Duration(seconds: 30),
                  (_) => _loadVehicles(filterRegNo: state.bus.busRegisterNumber),
            );
          }
        },
        child: Column(
          children: [
            if (widget.student.transport == '')
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 250.0),
                child: Center(child: Text('Transport is not linked')),
              ),
            if (widget.student.transport != '')
              BlocBuilder<BusBloc, BusState>(
                builder: (context, state) {
                  if (state is BusLoaded) {
                    return Expanded(
                      child: Column(
                        children: [


                  if (state.bus.gpsLocation.isNotEmpty)
                            Expanded(
                              child: Stack(
                                children: [

                                  GoogleMap(
                                    initialCameraPosition: const CameraPosition(
                                      target: LatLng(20.5937, 78.9629),
                                      zoom: 5,
                                    ),
                                    markers: _markers,
                                    onMapCreated: (controller) =>
                                    _mapController = controller,
                                  ),
                                  Positioned(
                                    top:10,
                                    left:10,right:10,
                                    child:     Container(
                                      decoration: BoxDecoration(
                                        color:Color(0xFFf4efef),
                                        borderRadius: BorderRadius.circular(8)

                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Bus No. and Reg No.
                                          // Bus No. and Reg No.
                                          Row(
                                            children: [
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(fontSize: 14, color: Colors.black),
                                                    children: [
                                                      const TextSpan(text: "Bus No. : "),
                                                      TextSpan(
                                                        text: state.bus.busNo,
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(fontSize: 14, color: Colors.black),
                                                    children: [
                                                      const TextSpan(text: "Reg. No. : "),
                                                      TextSpan(
                                                        text: state.bus.busRegisterNumber,
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),

// Route and Stage
//                                           Row(
//                                             children: [
//                                               Expanded(
//                                                 child: RichText(
//                                                   text: TextSpan(
//                                                     style: const TextStyle(fontSize: 12, color: Colors.black),
//                                                     children: [
//                                                       const TextSpan(text: "Route : "),
//                                                       TextSpan(
//                                                         text: widget.student.routeName,
//                                                         style: const TextStyle(fontWeight: FontWeight.bold),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                               Expanded(
//                                                 child: RichText(
//                                                   text: TextSpan(
//                                                     style: const TextStyle(fontSize: 12, color: Colors.black),
//                                                     children: [
//                                                       const TextSpan(text: "Stage : "),
//                                                       TextSpan(
//                                                         text: widget.student.stageName,
//                                                         style: const TextStyle(fontWeight: FontWeight.bold),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),

                                        ],
                                      ),
                                    ),),

                                  if (_mapError != null)
                                    Positioned(
                                         bottom: 50,
                                      left: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _mapError!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          if(state.bus.gpsLocation.isEmpty)
                  Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: Container(
                    color: Colors.grey[100], // background for the panel
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Center(
                    child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                    BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    ),
                    ],
                    ),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                    "Bus Details",
                    style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                    children: [
                    const Text("Bus No.: ", style: TextStyle(fontSize: 16, color: Colors.black87)),
                    Text(state.bus.busNo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                    children: [
                    const Text("Reg. No.: ", style: TextStyle(fontSize: 16, color: Colors.black87)),
                    Text(state.bus.busRegisterNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                    children: const [
                    Text("GPS Status: ", style: TextStyle(fontSize: 16, color: Colors.black87)),
                    Text("Yet to be linked", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontStyle: FontStyle.italic)),
                    ],
                    ),
                    ],
                    ),
                    ),
                    ),
                    ),
                  ),
                  ),


                  ],
                      ),
                    );
                  } else if (state is BusLoading) {
                    return const Loader();
                  }
                  else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 200,
                        ),
                        child: Text('No Transport Linked'),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
