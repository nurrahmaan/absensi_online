import 'package:flutter/material.dart';

class DocumentPreviewScreen extends StatelessWidget {
  final String title;
  final String fileType;

  const DocumentPreviewScreen({
    super.key,
    required this.title,
    required this.fileType,
  });

  @override
  Widget build(BuildContext context) {
    Widget previewContent;

    switch (fileType) {
      case "pdf":
        previewContent =
            const Icon(Icons.picture_as_pdf, size: 120, color: Colors.red);
        break;
      case "docx":
        previewContent =
            const Icon(Icons.description, size: 120, color: Colors.green);
        break;
      case "xlsx":
        previewContent =
            const Icon(Icons.table_chart, size: 120, color: Colors.orange);
        break;
      default:
        previewContent =
            const Icon(Icons.insert_drive_file, size: 120, color: Colors.grey);
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            previewContent,
            const SizedBox(height: 20),
            Text(
              "Preview Dummy untuk $title",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Tipe file: $fileType",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Download"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Downloading $title...")),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
