import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hopelink/main.dart';

//REPORT DETAIL PAGE

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  // helper to determine if the string is a Base64 image
  bool _isBase64(String s) {
    return s.length > 50 && !s.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    // check for asset image
    if (report.imageUrl.startsWith('asset:')) {
      final assetPath = report.imageUrl.replaceFirst('asset:', '');
      imageWidget = Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder("Asset image not found.");
        },
      );
    }
    // check for base64
    else if (_isBase64(report.imageUrl)) {
      try {
        final bytes = base64Decode(report.imageUrl);
        imageWidget = Image.memory(bytes, fit: BoxFit.cover);
      } catch (e) {
        imageWidget = _buildErrorPlaceholder('Base64 Decoding Error');
      }
    }
    // else, treat as network
    else {
      imageWidget = Image.network(
        report.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder("No Image Provided");
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(report.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display Image (network or memory)
            Container(
              height: 500, // Increased height
              width: double.infinity,
              color: Colors.grey.shade200,
              child: imageWidget,
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: report.type == ReportType.Missing
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.type == ReportType.Missing
                          ? 'MISSING REPORT'
                          : 'FOUND REPORT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Details / Identification:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Date Reported
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reported on: ${report.date.month}/${report.date.day}/${report.date.year}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //custom error placeholder widget
  Widget _buildErrorPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            report.type == ReportType.Missing
                ? Icons.image_not_supported
                : Icons.photo,
            size: 50,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
