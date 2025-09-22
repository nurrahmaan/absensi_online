import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/absensi/add_assignment_provider.dart';
import '../../widgets/notifications/top_notification.dart';

class AddAssignmentScreen extends StatefulWidget {
  final String token;

  const AddAssignmentScreen({
    super.key,
    required this.token,
  });

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _uraianController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jamMasukController = TextEditingController();
  final TextEditingController _jamPulangController = TextEditingController();

  /// Date Picker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// Time Picker
  Future<void> _pickTime(bool isMasuk) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final jam = picked.format(context);
      setState(() {
        if (isMasuk) {
          _jamMasukController.text = jam;
        } else {
          _jamPulangController.text = jam;
        }
      });
    }
  }

  void _submit(AddAssignmentProvider provider) async {
    if (_formKey.currentState?.validate() != true) return;

    final payload = {
      "nipExtra": provider.selectedKaryawanId,
      "kategori": provider.kategori,
      "tanggal": _tanggalController.text,
      "jam_masuk": _jamMasukController.text,
      "jam_pulang": _jamPulangController.text,
      "dihari": provider.dihari,
    };

    // print("Payload dikirim ke API: $payload");

    final res = await provider.submitAssignment(payload);

    if (res['success'] == true) {
      showTopNotification(
        context,
        res['message'],
        type: NotificationType.success,
      );
      Navigator.pop(context, true);
    } else {
      showTopNotification(
        context,
        res['message'],
        type: NotificationType.error,
      );
    }
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool multiline = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: multiline ? 3 : 1,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700)),
            ),
            Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddAssignmentProvider(token: widget.token),
      child: Consumer<AddAssignmentProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              backgroundColor: Colors.blue.shade600,
              elevation: 0,
              title: const Text(
                "Tambah Assignment",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildSectionTitle("Informasi Umum"),

                            // Dropdown Karyawan
                            provider.isLoadingKaryawan
                                ? const CircularProgressIndicator()
                                : DropdownButtonFormField<String>(
                                    value: provider.selectedKaryawanId,
                                    items: provider.karyawanList.map((e) {
                                      final username =
                                          e['username']?.toString() ?? '';
                                      final nama = e['nama']?.toString() ?? '';
                                      return DropdownMenuItem<String>(
                                        value: username,
                                        child: Text(nama),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: "Nama Karyawan",
                                      prefixIcon: Icon(Icons.person,
                                          color: Colors.blue.shade600),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 16),
                                    ),
                                    onChanged: (val) =>
                                        provider.selectedKaryawanId = val,
                                    validator: (v) => v == null
                                        ? "Pilih karyawan dulu"
                                        : null,
                                  ),
                            const SizedBox(height: 16),

                            // Dropdown Kategori
                            DropdownButtonFormField<String>(
                              value: provider.kategori,
                              items: ["Piket", "Lembur"]
                                  .map((e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: "Kategori",
                                prefixIcon: Icon(Icons.category,
                                    color: Colors.blue.shade600),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                              ),
                              onChanged: (val) {
                                provider.kategori = val;
                                provider.dihari = null; // reset
                              },
                              validator: (v) =>
                                  v == null ? "Pilih kategori dulu" : null,
                            ),
                            const SizedBox(height: 16),

                            // Uraian
                            _buildInput(
                              label: "Uraian",
                              icon: Icons.description,
                              controller: _uraianController,
                              multiline: true,
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Wajib diisi" : null,
                            ),
                            const SizedBox(height: 16),

                            // Dropdown Dihari
                            if (provider.getDihariOptions().isNotEmpty)
                              DropdownButtonFormField<String>(
                                value: provider.dihari,
                                items: provider
                                    .getDihariOptions()
                                    .map((e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                decoration: InputDecoration(
                                  labelText: "Dihari",
                                  prefixIcon: Icon(Icons.event,
                                      color: Colors.blue.shade600),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                                onChanged: (val) => provider.dihari = val,
                                validator: (v) =>
                                    v == null ? "Pilih dihari dulu" : null,
                              ),

                            _buildSectionTitle("Jadwal"),

                            _buildInput(
                              label: "Tanggal",
                              icon: Icons.calendar_today,
                              controller: _tanggalController,
                              onTap: _pickDate,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Wajib dipilih"
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInput(
                                    label: "Jam Masuk",
                                    icon: Icons.access_time,
                                    controller: _jamMasukController,
                                    onTap: () => _pickTime(true),
                                    validator: (v) => v == null || v.isEmpty
                                        ? "Wajib dipilih"
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInput(
                                    label: "Jam Pulang",
                                    icon: Icons.access_time_filled,
                                    controller: _jamPulangController,
                                    onTap: () => _pickTime(false),
                                    validator: (v) => v == null || v.isEmpty
                                        ? "Wajib dipilih"
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Tombol simpan
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: provider.isSubmitting
                          ? null
                          : () => _submit(provider),
                      icon: const Icon(Icons.save),
                      label: provider.isSubmitting
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Simpan Assignment",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
