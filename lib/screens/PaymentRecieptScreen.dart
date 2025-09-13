import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class PaymentReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> receiptData;

  const PaymentReceiptScreen({Key? key, required this.receiptData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(receiptData['paymentTimestamp']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Receipt"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Download PDF",
            onPressed: () async {
              final pdf = await generatePDF(receiptData);
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdf,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AutoVerse", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Divider(),
                _buildRow("Booking ID", receiptData['bookingId']),
                _buildRow("Car Name", receiptData['carName']),
                _buildRow("User Email", receiptData['email']),
                _buildRow("Amount Paid", "₹${receiptData['amountPaid']}"),
                _buildRow("Status", "Success"),
                _buildRow("Date", DateFormat.yMMMd().add_jm().format(dateTime)),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Done"),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<Uint8List> generatePDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final date = DateTime.parse(data['paymentTimestamp']);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("AutoVerse Receipt", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              _buildPdfRow("Booking ID", data['bookingId']),
              _buildPdfRow("Car Name", data['carName']),
              _buildPdfRow("User Email", data['email']),
              _buildPdfRow("Amount Paid", "₹${data['amountPaid']}"),
              _buildPdfRow("Status", "Success"),
              _buildPdfRow("Date", DateFormat.yMMMd().add_jm().format(date)),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text("Thank you for your payment!", style: pw.TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Text("$title: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
