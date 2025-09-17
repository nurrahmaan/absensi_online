import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  const DashboardScreen({required this.token, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _loading = true;

  Map<String, String> todayData = {};
  Map<String, int> monthSummary = {};
  List<Map<String, dynamic>> lastFiveDays = [];
  Map<String, dynamic> userProfile = {};

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fetchDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboard() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _apiService.getJadwalToday(widget.token),
        _apiService.getMonthlySummary(widget.token),
        _apiService.getLastFiveDays(widget.token),
        _apiService.getUserProfile(widget.token),
      ]);

      final today = results[0] as Map<String, dynamic>;
      final summary = results[1] as Map<String, dynamic>;
      final last5 = results[2] as List<Map<String, dynamic>>;
      final profile = results[3] as Map<String, dynamic>;

      setState(() {
        userProfile = profile;

        todayData = {
          'jadwal_masuk': today['jam_masuk']?.toString() ?? '-',
          'jadwal_pulang': today['jam_pulang']?.toString() ?? '-',
          'absen_masuk': today['masuk_jam']?.toString() ?? '-',
          'absen_pulang': today['pulang_jam']?.toString() ?? '-',
          'status': (today['masuk_jam'] == null)
              ? 'Belum Absen'
              : (today['telat'] == 'n'
                  ? 'On-time'
                  : 'Telat ${today['durasi_telat'] ?? '0'}m'),
          'lokasi': profile['lokasi_absen'] ?? '-',
        };

        monthSummary = {
          'hadir': int.tryParse(summary['hadir']?.toString() ?? '0') ?? 0,
          'alpha': int.tryParse(summary['alpha']?.toString() ?? '0') ?? 0,
          'telat': int.tryParse(summary['telat']?.toString() ?? '0') ?? 0,
          'piket': int.tryParse(summary['piket']?.toString() ?? '0') ?? 0,
        };

        lastFiveDays = last5;
        _loading = false;
      });

      _controller.forward(from: 0);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: _fetchDashboard,
        child: _loading
            ? Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: ListView(
                  children: List.generate(
                      6,
                      (index) => Container(
                            height: 100,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)),
                          )),
                ),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF512DA8), Color(0xFF7E57C2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  (userProfile['nama'] != null &&
                                          userProfile['nama'].isNotEmpty)
                                      ? userProfile['nama'][0].toUpperCase()
                                      : 'R',
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userProfile['nama'] ?? '-',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      userProfile['department'] ?? '-',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {},
                                icon: const Icon(Icons.flash_on),
                                label: const Text('Quick Absen'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: -60,
                          left: 16,
                          right: 16,
                          child: _buildAttendanceCard(),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 80, bottom: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          _buildMonthlySummaryCard(),
                          const SizedBox(height: 20), // <-- spasi 20px
                          _buildLastFiveDays(),
                        ],
                      ),
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
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F0),
          borderRadius: BorderRadius.circular(18),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF512DA8), Color(0xFF7E57C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem('Hadir', monthSummary['hadir'] ?? 0,
                Icons.check_circle, Colors.greenAccent),
            _summaryItem('Alpha', monthSummary['alpha'] ?? 0, Icons.cancel,
                Colors.redAccent),
            _summaryItem('Telat', monthSummary['telat'] ?? 0, Icons.access_time,
                Colors.orangeAccent),
            _summaryItem('Piket', monthSummary['piket'] ?? 0,
                Icons.assignment_ind, Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, int value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
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
        color: Colors.black.withOpacity(0.05),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lastFiveDays.length,
              itemBuilder: (context, index) {
                return _buildLastFiveItem(lastFiveDays[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLastFiveItem(Map<String, dynamic> item) {
    bool hasStatus = item['status'] != null && item['status'].isNotEmpty;

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

    Color badgeColor;
    switch (item['tipe_kehadiran']) {
      case 'piket':
        badgeColor = Colors.blueAccent;
        break;
      case 'libur':
        badgeColor = Colors.green;
        break;
      default:
        badgeColor = Colors.orangeAccent;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
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
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Pulang: ${item['pulang']}",
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (hasStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
  }
}
