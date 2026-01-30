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

  // 🔹 Added analytics
  double yearlyTotalRevenue = 0;
  double averageMonthlyRevenue = 0;
  int? bestMonth;
  int? worstMonth;

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

      final Map<int, double> tempMonthly = {};

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

            final price =
                double.tryParse(bookingData["finalPrice"]?.toString() ?? "0") ?? 0;

            tempMonthly[date.month] =
                (tempMonthly[date.month] ?? 0) + price;
          });
        }
      });

      final now = DateTime.now();

      setState(() {
        // ✅ assign final monthly data
        monthlyRevenue = tempMonthly;

        currentMonthRevenue = monthlyRevenue[now.month] ?? 0;
        previousMonthRevenue =
            monthlyRevenue[now.month == 1 ? 12 : now.month - 1] ?? 0;

        // ✅ YEARLY TOTAL (correct)
        yearlyTotalRevenue =
            monthlyRevenue.values.fold(0.0, (sum, v) => sum + v);

        // ✅ AVG PER MONTH (correct)
        averageMonthlyRevenue = yearlyTotalRevenue / 12;

        // ✅ BEST & WORST
        if (monthlyRevenue.isNotEmpty) {
          bestMonth = monthlyRevenue.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;

          worstMonth = monthlyRevenue.entries
              .reduce((a, b) => a.value < b.value ? a : b)
              .key;
        }

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

    final List<FlSpot> spots = List.generate(12, (index) {
      final month = index + 1;
      return FlSpot(month.toDouble(), monthlyRevenue[month] ?? 0);
    });

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxValue == 0 ? 1000 : maxValue * 1.2,
            gridData: FlGridData(
              show: true,
              horizontalInterval: maxValue == 0 ? 250 : maxValue / 4,
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => ColorSys.purple1,
                tooltipRoundedRadius: 10,
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    final m = spot.x.toInt();
                    return LineTooltipItem(
                      "${months[m - 1]}\n₹${spot.y.toStringAsFixed(0)}",
                      const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 46,
                  interval: maxValue == 0 ? 250 : maxValue / 4,
                  getTitlesWidget: (value, _) => Text(
                    _formatYAxis(value),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
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
                spots: spots,
                isCurved: true,
                preventCurveOverShooting: true,
                color: Colors.deepPurple,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, _) => spot.y > 0,
                ),
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
    }
    return "₹${value.toInt()}";
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          const SizedBox(height: 10),
          Text("📊 Yearly Revenue: ₹${yearlyTotalRevenue.toStringAsFixed(0)}"),
          Text("📐 Avg / Month: ₹${averageMonthlyRevenue.toStringAsFixed(0)}"),
          if (bestMonth != null)
            Text("🏆 Best Month: ${months[bestMonth! - 1]}"),
          if (worstMonth != null)
            Text("⚠️ Lowest Month: ${months[worstMonth! - 1]}"),
        ]),
      ),
    );
  }

  // ======================= PDF =======================
  Widget _exportPdfButton() {
    return ElevatedButton.icon(
      onPressed: _exportAnalyticsPdf,
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text("Export Analytics PDF"),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorSys.purple1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

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
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(),
            children: List.generate(12, (index) {
              final m = index + 1;
              return pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(months[index]),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    "₹${(monthlyRevenue[m] ?? 0).toStringAsFixed(0)}",
                  ),
                ),
              ]);
            }),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }
}
