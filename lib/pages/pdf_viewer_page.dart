// ===== lib/pages/pdf_viewer_page.dart =====
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import '../providers/language_provider.dart';

class PdfViewerPage extends StatelessWidget {
  final String? filePath;
  final String? assetPath;
  final String title;
  final bool isAsset;

  const PdfViewerPage({
    super.key,
    this.filePath,
    this.assetPath,
    required this.title,
    required this.isAsset,
  });

  // Méthode pour obtenir la traduction
  String _tr(String key) {
    return LanguageProvider().translate(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red[600],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red[50]!,
              Colors.white,
            ],
          ),
        ),
        child: isAsset
            ? SfPdfViewer.asset(
                assetPath!,
                enableDoubleTapZooming: true,
                enableTextSelection: true,
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${_tr('medications.pdf.pdf_render_error')}: ${details.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              )
            : SfPdfViewer.file(
                File(filePath!),
                enableDoubleTapZooming: true,
                enableTextSelection: true,
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${_tr('medications.pdf.pdf_render_error')}: ${details.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
      ),
    );
  }
}