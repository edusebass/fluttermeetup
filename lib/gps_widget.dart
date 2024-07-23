import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'src/widgets.dart';

class GPSWidget extends StatefulWidget {
  const GPSWidget({super.key});
  @override
  GPSWidgetState createState() => GPSWidgetState();
}

class GPSWidgetState extends State<GPSWidget> {
  String _locationMessage = "";
  LatLng _currentLocation = const LatLng(-0.210011, -78.485954);
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _getCurrentLocation() async {
    try {
      if (!kIsWeb) {
        // Para dispositivos móviles
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            _locationMessage = "Location services are disabled.";
          });
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            setState(() {
              _locationMessage = "Location permissions are denied.";
            });
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          setState(() {
            _locationMessage = "Location permissions are permanently denied.";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _locationMessage =
            "Latitud: ${position.latitude}\nLongitud: ${position.longitude}";
        _currentLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentLocation, 15.0);
      });
    } catch (e) {
      setState(() {
        _locationMessage = "Failed to get location: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 300,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const [],
                tileProvider: CancellableNetworkTileProvider(),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 30.0,
                    height: 30.0,
                    child: Container(
                      color: Colors.red,
                      child: const Icon(Icons.location_on,
                          color: Colors.white, size: 20.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Paragraph(
          'Presiona el botón para ver tu ubicación en tiempo real',
        ),
        const SizedBox(height: 10),
        Text(
          _locationMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        StyledButton(
          onPressed: _getCurrentLocation,
          child: const Text('Ver mi ubicación'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
