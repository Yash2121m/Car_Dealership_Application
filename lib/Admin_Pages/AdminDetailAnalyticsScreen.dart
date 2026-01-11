import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../Assistance/ColorHelper.dart';

class AdminDetailAnalytics extends StatefulWidget {
  const AdminDetailAnalytics({Key? key}) : super(key: key);

  @override
  State<AdminDetailAnalytics> createState() => _AdminDetailAnalyticsState();
}

class _AdminDetailAnalyticsState extends State<AdminDetailAnalytics> {
  final DatabaseReference bookingsRef =
  FirebaseDatabase.instance.ref().child("bookings");

  final List<String> months = const [
    "Jan","Feb","Mar","Apr","May","Jun",
    "Jul","Aug","Sep","Oct","Nov","Dec"
  ];

  Map<int, double> monthlyRevenue = {};
  double currentMonthRevenue = 0;
  double previousMonthRevenue = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetailedAnalytics();
  }

  // ======================= DATA =======================
  void _fetchDetailedAnalytics() {
    bookingsRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      monthlyRevenue.clear();

      final users = event.snapshot.value as Map<dynamic, dynamic>;

      users.forEach((_, userBookings) {
        if (userBookings is Map) {
          userBookings.forEach((_, bookingData) {
            if (bookingData is! Map ||
                bookingData["timestamp"] == null ||
                bookingData["status"] != "approved") return;

            DateTime date;
            try {
              date = DateTime.parse(bookingData["timestamp"]);
            } catch (_) {
              return;
            }

            final double price =
                double.tryParse(bookingData["finalPrice"]?.toString() ?? "0") ??
                    0;

            monthlyRevenue[date.month] =
                (monthlyRevenue[date.month] ?? 0) + price;
          });
        }
      });

      final now = DateTime.now();
      currentMonthRevenue = monthlyRevenue[now.month] ?? 0;
      previousMonthRevenue =
          monthlyRevenue[now.month == 1 ? 12 : now.month - 1] ?? 0;

      setState(() {
        isLoading = false;
      });
    });
  }

  // ======================= UI =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient:
            LinearGradient(colors: [ColorSys.purple1, ColorSys.purple2]),
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: AppBar(
            title: const Text(
              "Detailed Analytics",
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Monthly Revenue Trend",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(height: 250, child: _monthlyRevenueChart()),

          const SizedBox(height: 24),
          _monthComparisonCard(),

          const SizedBox(height: 24),
          Center(child: _exportPdfButton()),
        ],
      ),
    );
  }

  // ======================= LINE CHART =======================
  Widget _monthlyRevenueChart() {
    final maxValue = monthlyRevenue.values.isEmpty
        ? 0
        : monthlyRevenue.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxValue * 1.2,
            gridData: FlGridData(
              show: true,
              horizontalInterval: maxValue / 4,
            ),
            titlesData: FlTitlesData(
              topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),

              /// ✅ FIXED LEFT AXIS
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 46,
                  interval: maxValue / 4,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _formatYAxis(value),
                      style: const TextStyle(fontSize: 11),
                    );
                  },
                ),
              ),

              /// Bottom month labels
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, _) {
                    int m = value.toInt();
                    if (m < 1 || m > 12) return const SizedBox.shrink();
                    return Text(
                      months[m - 1],
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: monthlyRevenue.entries
                    .map((e) => FlSpot(
                  e.key.toDouble(),
                  e.value,
                ))
                    .toList(),
                isCurved: true,
                color: Colors.deepPurple,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.deepPurple.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String _formatYAxis(double value) {
    if (value >= 10000000) {
      return "₹${(value / 10000000).toStringAsFixed(1)}Cr";
    } else if (value >= 100000) {
      return "₹${(value / 100000).toStringAsFixed(1)}L";
    } else if (value >= 1000) {
      return "₹${(value / 1000).toStringAsFixed(0)}K";
    } else {
      return "₹${value.toInt()}";
    }
  }


  // ======================= COMPARISON =======================
  Widget _monthComparisonCard() {
    final diff = currentMonthRevenue - previousMonthRevenue;
    final percent = previousMonthRevenue == 0
        ? 0
        : (diff / previousMonthRevenue) * 100;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Month Comparison",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("This Month: ₹${currentMonthRevenue.toStringAsFixed(0)}"),
            Text("Last Month: ₹${previousMonthRevenue.toStringAsFixed(0)}"),
            const SizedBox(height: 6),
            Text(
              percent >= 0
                  ? "📈 Growth: ${percent.toStringAsFixed(1)}%"
                  : "📉 Drop: ${percent.toStringAsFixed(1)}%",
              style: TextStyle(
                  color: percent >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ======================= PDF BUTTON =======================
  // Widget _exportPdfButton() {
  //   return ElevatedButton.icon(
  //     onPressed: () {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("PDF export coming soon 🚀")),
  //       );
  //     },
  //     icon: const Icon(Icons.picture_as_pdf),
  //     label: const Text("Export Analytics PDF"),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: ColorSys.purple2,
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(30),
  //       ),
  //     ),
  //   );
  // }

  Widget _exportPdfButton() {
    return ElevatedButton.icon(
      onPressed: _exportAnalyticsPdf,
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text("Export Analytics PDF"),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorSys.purple2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  // ======================= PDF EXPORT =======================
  Future<void> _exportAnalyticsPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            "Admin Sales Analytics Report",
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text(
            "Generated on: ${DateTime.now()}",
            style: const pw.TextStyle(fontSize: 10),
          ),

          pw.Divider(),

          pw.SizedBox(height: 12),

          _pdfRow("Current Month Revenue",
              "₹${currentMonthRevenue.toStringAsFixed(0)}"),
          _pdfRow("Previous Month Revenue",
              "₹${previousMonthRevenue.toStringAsFixed(0)}"),

          pw.SizedBox(height: 20),

          pw.Text(
            "Monthly Revenue Summary",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Table(
            border: pw.TableBorder.all(),
            children: monthlyRevenue.entries.map((e) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(months[e.key - 1]),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text("₹${e.value.toStringAsFixed(0)}"),
                  ),
                ],
              );
            }).toList(),
          ),

          pw.SizedBox(height: 24),

          pw.Text(
            "Generated by Admin Panel",
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey,
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  pw.Widget _pdfRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }



}
