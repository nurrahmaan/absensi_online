import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../widgets/notifications/top_notification.dart';

class AbsenPulangShiftMalamScreen extends StatefulWidget {
  final String token;
  const AbsenPulangShiftMalamScreen({required this.token, super.key});

  @override
  State<AbsenPulangShiftMalamScreen> createState() =>
      _AbsenPulangShiftMalamScreenState();
}

class _AbsenPulangShiftMalamScreenState
    extends State<AbsenPulangShiftMalamScreen> {
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
    _timer =
        Timer.periodic(const Duration(seconds: 10), (_) => _checkConnections());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnections() async {
    final internet = await _apiService.hasInternetConnection();
    final server = internet ? await _apiService.hasServerConnection() : false;

    // Sinkronisasi offline
    if (_hasServer == false && server == true && _offlineAbsenList.isNotEmpty) {
      for (var lokasi in _offlineAbsenList) {
        await _apiService.absen(widget.token, "out"); // khusus shift malam
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

  Future<void> _fetchLokasiKantor() async {
    List<Map<String, dynamic>> kantorList = [];
    final prefs = await SharedPreferences.getInstance();

    if (_hasInternet && _hasServer) {
      kantorList = await _apiService.getLokasiKantor(widget.token);
      prefs.setString('kantor_data', jsonEncode(kantorList));
    } else {
      final jsonStr = prefs.getString('kantor_data');
      if (jsonStr != null) {
        final List<dynamic> data = jsonDecode(jsonStr);
        kantorList = List<Map<String, dynamic>>.from(data);
      }
    }

    kantorList = kantorList.where((e) => e['aktif'] == "Y").toList();

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
    const double earthRadius = 6371000;
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
        30.0;
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

  void _absenOnline(String lokasi) async {
    final result = await _apiService.absen(widget.token, "out");

    final success = result["status"] == "success";
    final message = result["message"] ??
        (success
            ? "Absen pulang shift malam di $lokasi berhasil"
            : "Gagal absen pulang shift malam di $lokasi");

    showTopNotification(
      context,
      message,
      title: success ? "Absensi Berhasil" : "Absensi Gagal",
      icon: success ? Icons.check_circle : Icons.error,
      type: success ? NotificationType.success : NotificationType.error,
    );
  }

  void _absenOffline(String lokasi) {
    _offlineAbsenList.add(lokasi);

    showTopNotification(
      context,
      "Absen offline di $lokasi tersimpan sementara",
      title: "Absen Offline",
      icon: Icons.cloud_off,
    );
  }

  Widget _listKantorWidget(bool isOnline) {
    return RefreshIndicator(
      onRefresh: () async => _checkConnections(),
      child: ListView.builder(
        itemCount: _lokasiKantor.length,
        itemBuilder: (context, index) {
          final lokasi = _lokasiKantor[index];
          final lat = lokasi['lat'] ?? 0.0;
          final lng = lokasi['lng'] ?? 0.0;
          final withinRadius = _isWithinRadius(lat, lng);
          final jarak = _distanceFromCurrent(lat, lng);

          return Card(
            color: withinRadius ? Colors.green[100] : Colors.red[100],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(lokasi['name'] ?? "Tidak diketahui"),
              subtitle: withinRadius
                  ? const Text("Kamu berada di dalam lokasi absen")
                  : Text(
                      "Di luar jangkauan. Kamu ${jarak.toStringAsFixed(1)} m dari lokasi absen"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isOnline && _offlineAbsenList.contains(lokasi['name']))
                    const Icon(Icons.check_circle,
                        color: Colors.blue, size: 20),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_outlined),
                    onPressed: withinRadius
                        ? () {
                            if (isOnline) {
                              _absenOnline(lokasi['name']);
                            } else {
                              _absenOffline(lokasi['name']);
                            }
                          }
                        : () {
                            showTopNotification(
                              context,
                              "Kamu berada di luar jangkauan. Tidak bisa absen di ${lokasi['name']}",
                              type: NotificationType.error,
                            );
                          },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Tidak ada koneksi internet.\nPastikan koneksi internet kamu ada.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

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
                ListTile(
                  leading: Icon(Icons.nightlight_round, color: Colors.blue),
                  title: const Text(
                    "Absen Pulang Shift Malam",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: _listKantorWidget(_hasServer)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
