import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  const DashboardScreen({required this.token, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  bool _loading = true;

  Map<String, String> todayData = {
    'jadwal_masuk': '-',
    'jadwal_pulang': '-',
    'absen_masuk': '-',
    'absen_pulang': '-',
    'status': 'Belum Absen',
    'lokasi': '-',
  };

  Map<String, int> monthSummary = {
    'hadir': 0,
    'alpha': 0,
    'telat': 0,
    'piket': 0,
  };

  List<Map<String, dynamic>> lastFiveDays = [];
  Map<String, dynamic> userProfile = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() => _loading = true);

    try {
      final today = await _apiService.getJadwalToday(widget.token);
      if (today.isEmpty) {
        todayData = {
          'jadwal_masuk': '-',
          'jadwal_pulang': '-',
          'absen_masuk': '-',
          'absen_pulang': '-',
          'status': 'Belum Absen',
          'lokasi': '-',
        };
      } else {
        todayData = {
          'jadwal_masuk': today['jam_masuk']?.toString() ?? '-',
          'jadwal_pulang': today['jam_pulang']?.toString() ?? '-',
          'absen_masuk': today['masuk_jam']?.toString() ?? '-',
          'absen_pulang': today['pulang_jam']?.toString() ?? '-',
          'status': (today['masuk_jam'] == null && today['pulang_jam'] == null)
              ? 'Belum Absen'
              : (today['telat'] == null
                  ? 'On-time'
                  : 'Telat ${today['durasi_telat'] ?? '0'}m'),
          'lokasi': 'Kantor Pusat',
        };
      }

      final summary = await _apiService.getMonthlySummary(widget.token);
      monthSummary = {
        'hadir': int.tryParse(summary['hadir']?.toString() ?? '0') ?? 0,
        'alpha': int.tryParse(summary['alpha']?.toString() ?? '0') ?? 0,
        'telat': int.tryParse(summary['telat']?.toString() ?? '0') ?? 0,
        'piket': int.tryParse(summary['piket']?.toString() ?? '0') ?? 0,
      };

      final last5 = await _apiService.getLastFiveDays(widget.token);
      lastFiveDays = last5.map((item) {
        return {
          'tanggal': item['tanggal'],
          'masuk': item['masuk'] ?? '-',
          'pulang': item['pulang'] ?? '-',
          'status': item['status'],
          'tipe_kehadiran': item['tipe_kehadiran'],
        };
      }).toList();

      final profile = await _apiService.getUserProfile(widget.token);
      userProfile = profile;
    } catch (e) {
      print('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔵 Isi dashboard
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Colors.lightBlueAccent),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchDashboard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildUserHeader(),
                          Transform.translate(
                            offset: const Offset(0, -75),
                            child: _buildAttendanceCard(),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -50),
                            child: _buildMonthlySummaryCard(),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: _buildLastFiveDays(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF512DA8), Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.deepPurple,
              child: Text(
                userProfile['nama'] != null
                    ? userProfile['nama'][0].toUpperCase()
                    : 'R', // fallback inisial
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProfile['nama'] ?? 'Rahman',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userProfile['jabatan'] ?? 'Jabatan / Dept',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // aksi quick absen
              },
              icon: const Icon(Icons.flash_on),
              label: const Text('Quick Absen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Attendance Card =================
  Widget _buildAttendanceCard() {
    Color statusColor;
    IconData statusIcon;

    switch (todayData['status']) {
      case 'On-time':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Belum Absen':
        statusColor = Colors.amber;
        statusIcon = Icons.warning_amber_rounded;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F0), // putih tulang
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn('Masuk', todayData['absen_masuk'] ?? '-'),
                _infoColumn('Pulang', todayData['absen_pulang'] ?? '-'),
                Column(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      todayData['status'] ?? 'Belum Absen',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jadwal: ${todayData['jadwal_masuk']} - ${todayData['jadwal_pulang']}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.black54, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      todayData['lokasi'] ?? '-',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: todayData['absen_masuk'] != '-' ? 1 : 0,
              color: Colors.lightBlueAccent,
              backgroundColor: Colors.grey[300],
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // ================= Monthly Summary =================
  Widget _buildMonthlySummaryCard() {
    return Card(
      color: Colors.blue.shade900.withOpacity(.70),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem('Hadir', monthSummary['hadir']!, Icons.check_circle,
                Colors.green),
            _summaryItem('Alpha', monthSummary['alpha']!, Icons.cancel,
                Colors.redAccent),
            _summaryItem('Telat', monthSummary['telat']!, Icons.access_time,
                Colors.orangeAccent),
            _summaryItem('Piket', monthSummary['piket']!, Icons.assignment_ind,
                Colors.white60),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, int value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: color.withOpacity(0.15), shape: BoxShape.circle),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(title,
            style: const TextStyle(fontSize: 12, color: Colors.white60)),
      ],
    );
  }

  // ================= Last Five Days =================
  Widget _buildLastFiveDays() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.05), // hitam soft background
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Absensi 5 Hari Terakhir",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (lastFiveDays.isEmpty)
            const Text(
              "Belum ada absensi 5 hari terakhir",
              style: TextStyle(color: Colors.black45, fontSize: 12),
            )
          else
            Column(
              children: lastFiveDays.map((item) {
                bool hasStatus =
                    item['status'] != null && item['status'].isNotEmpty;

                // Status color
                Color statusColor;
                switch (item['status']) {
                  case 'On-time':
                    statusColor = Colors.green;
                    break;
                  case 'Belum Absen':
                    statusColor = Colors.orange;
                    break;
                  case 'Alpa':
                    statusColor = Colors.redAccent;
                    break;
                  default:
                    statusColor = Colors.red;
                }

                // Badge color
                Color badgeColor;
                switch (item['tipe_kehadiran']) {
                  case 'piket':
                    badgeColor = Colors.blueAccent;
                    break;
                  case 'libur':
                    badgeColor = Colors.green;
                    break;
                  default:
                    badgeColor = Colors.orangeAccent; // peach soft
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white, // peach soft
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item['tanggal'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (item['tipe_kehadiran'] != null &&
                                    item['tipe_kehadiran'].isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['tipe_kehadiran'].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  "Masuk: ${item['masuk']}",
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Pulang: ${item['pulang']}",
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (hasStatus)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item['status'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
