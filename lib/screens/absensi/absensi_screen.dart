import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class AbsensiScreen extends StatefulWidget {
  final String token;

  const AbsensiScreen({required this.token, super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  final Location _location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _currentPosition;

  bool _isConnected = true; // simulasi koneksi API
  final double _radiusMeter = 30.0;

  final List<Map<String, dynamic>> _lokasiKantor = [
    {"name": "Kantor Pusat", "lat": -8.58997429, "lng": 116.11368783},
    {"name": "Cabang Mataram", "lat": -8.589, "lng": 116.121},
    {"name": "Cabang Lombok", "lat": -8.600, "lng": 116.150},
  ];

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    final position = await _location.getLocation();
    setState(() {
      _currentPosition = position;
    });
  }

  double _distance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // meter
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLng = (lng2 - lng1) * (pi / 180);
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            (sin(dLng / 2) * sin(dLng / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  bool _isWithinRadius(double lat, double lng) {
    if (_currentPosition == null) return false;
    double distance = _distance(
      _currentPosition!.latitude!,
      _currentPosition!.longitude!,
      lat,
      lng,
    );
    return distance <= _radiusMeter;
  }

  double _distanceFromCurrent(double lat, double lng) {
    if (_currentPosition == null) return 0.0;
    return _distance(
      _currentPosition!.latitude!,
      _currentPosition!.longitude!,
      lat,
      lng,
    );
  }

  void _absen(String lokasi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Absen di $lokasi berhasil"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isConnected)
              Expanded(
                child: ListView.builder(
                  itemCount: _lokasiKantor.length,
                  itemBuilder: (context, index) {
                    final lokasi = _lokasiKantor[index];
                    final withinRadius =
                        _isWithinRadius(lokasi['lat'], lokasi['lng']);
                    final jarak =
                        _distanceFromCurrent(lokasi['lat'], lokasi['lng']);

                    return Card(
                      elevation: 3,
                      color: withinRadius ? Colors.green[200] : Colors.red[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(lokasi['name']),
                        subtitle: withinRadius
                            ? const Text("Kamu berada di dalam lokasi absen")
                            : Text(
                                "Di luar jangkauan. Kamu berada ${jarak.toStringAsFixed(1)} m dari lokasi absen"),
                        trailing: withinRadius
                            ? IconButton(
                                icon: const Icon(Icons.check),
                                color: Colors.white,
                                onPressed: () => _absen(lokasi['name']),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            if (!_isConnected)
              Expanded(
                child: Center(
                  child: Card(
                    color: Colors.grey[300],
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Tidak dapat mengambil data lokasi. Cek koneksi internet.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
