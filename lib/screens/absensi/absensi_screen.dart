import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../../services/api_service.dart';

class AbsensiScreen extends StatefulWidget {
  final String token;
  const AbsensiScreen({required this.token, super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  final Location _location = Location();
  final ApiService _apiService = ApiService();
  LocationData? _currentPosition;
  final double _radiusMeter = 30.0;

  final List<Map<String, dynamic>> _lokasiKantor = [
    {"name": "Kantor Pusat", "lat": -8.58997429, "lng": 116.11368783},
    {"name": "Kantor Gebang", "lat": -8.6003893, "lng": 116.1171184},
    {"name": "Cabang Mataram", "lat": -8.589, "lng": 116.121},
    {"name": "Cabang Lombok", "lat": -8.600, "lng": 116.150},
  ];

  bool _hasInternet = false;
  bool _hasServer = false;
  Timer? _timer;

  // List offline absen sementara
  List<String> _offlineAbsenList = [];

  @override
  void initState() {
    super.initState();
    _checkLocation();
    _checkConnections();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnections();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnections() async {
    final internet = await _apiService.hasInternetConnection();
    final server = internet ? await _apiService.hasServerConnection() : false;

    // Sync offline absen jika server kembali online
    if (!_hasServer && server && _offlineAbsenList.isNotEmpty) {
      for (var lokasi in _offlineAbsenList) {
        await _apiService.absen(widget.token, "in"); // sesuaikan type
      }
      _offlineAbsenList.clear();
    }

    if (mounted) {
      setState(() {
        _hasInternet = internet;
        _hasServer = server;
      });
    }
  }

  Future<void> _checkLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
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
    return _distance(
          _currentPosition!.latitude!,
          _currentPosition!.longitude!,
          lat,
          lng,
        ) <=
        _radiusMeter;
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

  void _absenOnline(String lokasi) async {
    final result = await _apiService.absen(widget.token, "in");
    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Absen online di $lokasi berhasil"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal absen online di $lokasi"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _absenOffline(String lokasi) {
    _offlineAbsenList.add(lokasi);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Absen offline di $lokasi tersimpan sementara"),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _checkLocation();
        await _checkConnections();
      },
      child: !_hasInternet
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Tidak ada koneksi internet.\nPastikan koneksi internet kamu ada.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          : _hasServer
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              const ListTile(
                                leading: Icon(Icons.location_on,
                                    color: Colors.green),
                                title: Text(
                                  "Lokasi Absensi (Online)",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._lokasiKantor.map((lokasi) {
                                final withinRadius = _isWithinRadius(
                                    lokasi['lat'], lokasi['lng']);
                                final jarak = _distanceFromCurrent(
                                    lokasi['lat'], lokasi['lng']);
                                return Card(
                                  color: withinRadius
                                      ? Colors.green[200]
                                      : Colors.red[200],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    title: Text(lokasi['name']),
                                    subtitle: withinRadius
                                        ? const Text(
                                            "Kamu berada di dalam lokasi absen")
                                        : Text(
                                            "Di luar jangkauan. Kamu berada ${jarak.toStringAsFixed(1)} m dari lokasi absen"),
                                    trailing: withinRadius
                                        ? IconButton(
                                            icon: const Icon(
                                                Icons.chevron_right_outlined),
                                            color: Colors.white,
                                            onPressed: () =>
                                                _absenOnline(lokasi['name']),
                                          )
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        color: Colors.orange[200],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              const ListTile(
                                leading:
                                    Icon(Icons.cloud_off, color: Colors.orange),
                                title: Text(
                                  "Absen Offline",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Absen akan disimpan pada lokal storage dan akan disinkronisasi otomatis jika server online",
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._lokasiKantor.map((lokasi) {
                                final withinRadius = _isWithinRadius(
                                    lokasi['lat'], lokasi['lng']);
                                final jarak = _distanceFromCurrent(
                                    lokasi['lat'], lokasi['lng']);
                                return Card(
                                  color: withinRadius
                                      ? Colors.green[200]
                                      : Colors.red[200],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    title: Text(lokasi['name']),
                                    subtitle: withinRadius
                                        ? const Text(
                                            "Kamu berada di dalam lokasi absen")
                                        : Text(
                                            "Di luar jangkauan. Kamu berada ${jarak.toStringAsFixed(1)} m dari lokasi absen"),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_offlineAbsenList
                                            .contains(lokasi['name']))
                                          const Icon(Icons.check,
                                              color: Colors.blue, size: 20),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.chevron_right_outlined),
                                          color: Colors.white,
                                          onPressed: withinRadius
                                              ? () =>
                                                  _absenOffline(lokasi['name'])
                                              : () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Kamu berada di luar jangkauan. Tidak bisa absen di ${lokasi['name']}"),
                                                      backgroundColor:
                                                          Colors.red,
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    ),
                                                  );
                                                },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
