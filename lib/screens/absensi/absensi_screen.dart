import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../providers/absensi/absensi_provider.dart';

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

  List<Map<String, dynamic>> _lokasiKantor = [];
  List<String> _offlineAbsenList = [];

  bool _hasInternet = false;
  bool _hasServer = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkLocation();
    _checkConnections();
    // timer untuk cek koneksi berkala
    _timer =
        Timer.periodic(const Duration(seconds: 10), (_) => _checkConnections());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ===== Cek koneksi internet + server =====
  Future<void> _checkConnections() async {
    final internet = await _apiService.hasInternetConnection();
    final server = internet ? await _apiService.hasServerConnection() : false;

    // Sync offline absen jika server kembali online
    if (_hasServer == false && server == true && _offlineAbsenList.isNotEmpty) {
      for (var lokasi in _offlineAbsenList) {
        await _apiService.absenMasuk(
            widget.token, "in"); // type bisa disesuaikan
      }
      _offlineAbsenList.clear();
    }

    if (mounted) {
      setState(() {
        _hasInternet = internet;
        _hasServer = server;
      });
    }

    await _fetchLokasiKantor();
  }

  // ===== Ambil lokasi kantor dari API / SharedPreferences =====
  Future<void> _fetchLokasiKantor() async {
    List<Map<String, dynamic>> kantorList = [];
    final prefs = await SharedPreferences.getInstance();

    if (_hasInternet && _hasServer) {
      // ambil dari API
      kantorList = await _apiService.getLokasiKantor(widget.token);
      // simpan ke SharedPreferences
      prefs.setString('kantor_data', jsonEncode(kantorList));
    } else {
      // ambil dari SharedPreferences
      final jsonStr = prefs.getString('kantor_data');
      if (jsonStr != null) {
        final List<dynamic> data = jsonDecode(jsonStr);
        kantorList = List<Map<String, dynamic>>.from(data);
      }
    }

    // filter aktif
    kantorList = kantorList.where((e) => e['aktif'] == "Y").toList();

    // urutkan berdasarkan jarak dari user
    if (_currentPosition != null) {
      kantorList.sort((a, b) {
        final jarakA = _distanceFromCurrent(
          double.tryParse(a['lat'].toString()) ?? 0.0,
          double.tryParse(a['lng'].toString()) ?? 0.0,
        );
        final jarakB = _distanceFromCurrent(
          double.tryParse(b['lat'].toString()) ?? 0.0,
          double.tryParse(b['lng'].toString()) ?? 0.0,
        );
        return jarakA.compareTo(jarakB);
      });
    }

    if (mounted) {
      setState(() {
        _lokasiKantor = kantorList;
      });
    }
  }

  // ===== Cek lokasi user =====
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

  // ===== Hitung jarak antar koordinat =====
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
        30.0; // default radius, bisa disesuaikan per kantor
  }

  double _distanceFromCurrent(double lat, double lng) {
    if (_currentPosition == null) return double.infinity;
    return _distance(
      _currentPosition!.latitude!,
      _currentPosition!.longitude!,
      lat,
      lng,
    );
  }

  // ===== Absen Online =====
  void _absenOnline(String lokasi) async {
    final result = await _apiService.absenMasuk(widget.token, "in");
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

  // ===== Absen Offline =====
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
    if (!_hasInternet) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Tidak ada koneksi internet.\nPastikan koneksi internet kamu ada.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    Widget listKantorWidget(
        List<Map<String, dynamic>> kantorList, bool isOnline) {
      return RefreshIndicator(
        onRefresh: () async {
          await _checkConnections();
        },
        child: ListView.builder(
          itemCount: kantorList.length,
          itemBuilder: (context, index) {
            final lokasi = kantorList[index];
            final lat = lokasi['lat'] ?? 0.0;
            final lng = lokasi['lng'] ?? 0.0;
            final withinRadius = _isWithinRadius(lat, lng);
            final jarak = _distanceFromCurrent(lat, lng);

            return Card(
              color: withinRadius ? Colors.green[200] : Colors.red[200],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(lokasi['name'] ?? "Tidak diketahui"),
                subtitle: withinRadius
                    ? const Text("Kamu berada di dalam lokasi absen")
                    : Text(
                        "Di luar jangkauan. Kamu berada ${jarak.toStringAsFixed(1)} m dari lokasi absen"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isOnline && _offlineAbsenList.contains(lokasi['name']))
                      const Icon(Icons.check_circle,
                          color: Colors.blue, size: 20),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_outlined),
                      color: Colors.white,
                      onPressed: withinRadius
                          ? () {
                              context.read<AbsensiProvider>().absen(
                                    context,
                                    "in",
                                    hasInternet: _hasInternet,
                                    hasServer: _hasServer,
                                  );
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Kamu berada di luar jangkauan. Tidak bisa absen di ${lokasi['name']}"),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // Server online → card online
    if (_hasServer) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.location_on, color: Colors.green),
                    title: Text(
                      "Lokasi Absensi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: listKantorWidget(_lokasiKantor, true)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Server offline → card offline
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.orange[200],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.cloud_off, color: Colors.orange),
                  title: Text(
                    "Absen Offline",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Absen akan disimpan pada lokal storage dan akan disinkronisasi otomatis jika server online. Pastikan kamu tidak menghapus data aplikasinya!",
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: listKantorWidget(_lokasiKantor, false)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
