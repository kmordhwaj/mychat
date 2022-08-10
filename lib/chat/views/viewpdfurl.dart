import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:flutter/material.dart';

class ViewPdfUrl extends StatefulWidget {
  final String file;
  const ViewPdfUrl({Key? key, required this.file}) : super(key: key);

  @override
  State<ViewPdfUrl> createState() => _ViewPdfUrlState();
}

class _ViewPdfUrlState extends State<ViewPdfUrl> {
  PDFDocument doc = PDFDocument();

  @override
  void initState() {
    super.initState();
    viewNow();
  }

  viewNow() async {
    final docX = await PDFDocument.fromURL(widget.file);
    setState(() {
      doc = docX;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Pdf View')),
        body: PDFViewer(document: doc));
  }
}
