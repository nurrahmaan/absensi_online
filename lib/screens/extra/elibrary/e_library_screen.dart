import 'package:flutter/material.dart';
import 'document_preview_screen.dart';

class ELibraryScreen extends StatefulWidget {
  final String token;
  const ELibraryScreen({required this.token, super.key});

  @override
  State<ELibraryScreen> createState() => _ELibraryScreenState();
}

class _ELibraryScreenState extends State<ELibraryScreen> {
  String searchQuery = "";
  String selectedFilter = "all";

  final List<Map<String, String>> documents = [
    {"title": "Panduan Absensi Online", "file": "pdf"},
    {"title": "Peraturan Cuti & Izin", "file": "docx"},
    {"title": "Jadwal Kerja 2025", "file": "xlsx"},
    {"title": "Form Pengajuan Lembur", "file": "pdf"},
    {"title": "SOP Dispensasi", "file": "docx"},
    {"title": "Rekap Lembur September", "file": "xlsx"},
  ];

  IconData getFileIcon(String type) {
    switch (type) {
      case "pdf":
        return Icons.picture_as_pdf;
      case "docx":
        return Icons.description;
      case "xlsx":
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter berdasarkan search dan tipe file
    final filteredDocs = documents.where((doc) {
      final matchesSearch =
          doc['title']!.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter =
          (selectedFilter == "all" || doc['file'] == selectedFilter);
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Library"),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFilter,
              items: const [
                DropdownMenuItem(value: "all", child: Text("Semua")),
                DropdownMenuItem(value: "pdf", child: Text("PDF")),
                DropdownMenuItem(value: "docx", child: Text("DOCX")),
                DropdownMenuItem(value: "xlsx", child: Text("XLSX")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
              },
              icon: const Icon(Icons.filter_list, color: Colors.white),
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari dokumen...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // 📂 Grid dokumen
          Expanded(
            child: filteredDocs.isEmpty
                ? const Center(
                    child: Text("Tidak ada dokumen ditemukan"),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 kolom
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3 / 2,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final item = filteredDocs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DocumentPreviewScreen(
                                title: item['title']!,
                                fileType: item['file']!,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                getFileIcon(item['file']!),
                                size: 48,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  item['title']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
