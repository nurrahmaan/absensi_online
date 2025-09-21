import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/notifications/top_notification.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAssignmentScreen extends StatefulWidget {
  final String token;
  const AddAssignmentScreen({required this.token, super.key});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  final ApiService _apiService = ApiService();

  Future<void> _submitAssignment() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      showTopNotification(context, "Lengkapi semua field",
          type: NotificationType.error);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _apiService.addAssignment(
      token: widget.token,
      name: _nameController.text,
      date: _selectedDate!,
      startTime: _startTime!,
      endTime: _endTime!,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true) {
      showTopNotification(context, "Assignment berhasil ditambahkan",
          type: NotificationType.success);
      Navigator.pop(context, true); // kembali ke layar sebelumnya
    } else {
      showTopNotification(
          context, result['message'] ?? "Gagal menambahkan assignment",
          type: NotificationType.error);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Assignment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Karyawan",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? "Pilih Tanggal"
                    : "Tanggal: ${_selectedDate!.toLocal().toIso8601String().split('T')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(_startTime == null
                    ? "Jam Masuk"
                    : "Jam Masuk: ${_startTime!.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(_endTime == null
                    ? "Jam Keluar"
                    : "Jam Keluar: ${_endTime!.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAssignment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Submit", style: GoogleFonts.poppins(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
