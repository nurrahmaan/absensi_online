import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../providers/server_connection_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Kantor {
  final String name;
  final double lat;
  final double lon;
  Kantor({required this.name, required this.lat, required this.lon});
}

List<Kantor> kantorList = [
  Kantor(name: 'Kantor A', lat: -8.583069, lon: 116.320251),
  Kantor(name: 'Kantor B', lat: -8.584000, lon: 116.321000),
];

class AbsensiScreen extends StatefulWidget {
  final String token;
  const AbsensiScreen({required this.token, super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  LocationData? currentPosition;
  Timer? _timer;
  final Location location = Location();

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    _timer = Timer.periodic(
        const Duration(seconds: 5), (_) => _getCurrentPosition());
    // cek koneksi global
    final serverProvider =
        Provider.of<ServerConnectionProvider>(context, listen: false);
    serverProvider.checkConnection();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentPosition() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final pos = await location.getLocation();
    setState(() => currentPosition = pos);
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> _absenOffline(String kantorName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> offlineList = prefs.getStringList('offline_absen') ?? [];
    offlineList.add('$kantorName - ${DateTime.now()}');
    await prefs.setStringList('offline_absen', offlineList);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Absen offline berhasil!')));
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<ServerConnectionProvider>(context);

    if (currentPosition == null)
      return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: ListView(
        children: [
          if (!serverProvider.isConnected)
            Card(
              color: Colors.red[100],
              child: ListTile(
                leading:
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                title: const Text('Tidak terkoneksi ke server!'),
                subtitle: const Text('Silakan cek koneksi internet Anda.'),
              ),
            ),
          if (serverProvider.isConnected) _buildPilihLokasi(),
          _buildAbsenOffline(),
        ],
      ),
    );
  }

  Widget _buildPilihLokasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Lokasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...kantorList.map((kantor) {
          final distance = _calculateDistance(currentPosition!.latitude!,
              currentPosition!.longitude!, kantor.lat, kantor.lon);
          final canCheckIn = distance <= 30;
          return Card(
            color: canCheckIn ? Colors.green[100] : Colors.red[100],
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(kantor.name),
              subtitle: Text('${distance.toStringAsFixed(1)} m'),
              enabled: canCheckIn,
              onTap: canCheckIn
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Absen berhasil!')));
                    }
                  : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAbsenOffline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Absen Offline',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...kantorList.map((kantor) {
          return Card(
            color: Colors.orange[100],
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.offline_pin, color: Colors.orange),
              title: Text(kantor.name),
              onTap: () => _absenOffline(kantor.name),
            ),
          );
        }).toList(),
      ],
    );
  }
}
