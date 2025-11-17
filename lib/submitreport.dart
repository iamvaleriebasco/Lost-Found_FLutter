import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hopelink/main.dart';
import 'package:image_picker/image_picker.dart';

class SubmitReportPage extends StatefulWidget {
  final Future <void> Function(Report) onSubmit;

  const SubmitReportPage({super.key, required this.onSubmit});

  @override
  State<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {
  Uint8List? webImage;
  File? mobileImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // On web, get image bytes
        webImage = await pickedFile.readAsBytes();
      } else {
        // On mobile/desktop, get file reference
        mobileImage = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: pickImage, child: Text('Pick Photo')),
            SizedBox(height: 20),
            if (kIsWeb && webImage != null) ...[
              Image.memory(webImage!, width: 200, height: 200),
            ] else if (!kIsWeb && mobileImage != null) ...[
              Image.file(mobileImage!, width: 200, height: 200),
            ] else ...[
              Text('No image selected.'),
            ],
            // Add other fields for your report submission here
          ],
        ),
      ),
    );
  }
}
