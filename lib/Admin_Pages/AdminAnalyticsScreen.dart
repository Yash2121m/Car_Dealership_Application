import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

import '../Assistance/ColorHelper.dart';
import 'AdminDetailAnalyticsScreen.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final DatabaseReference bookingsRef =
  FirebaseDatabase.instance.ref().child("bookings");

  int totalOrders = 0;
  int approvedOrders = 0;
  int pendingOrders = 0;
  int rejectedOrders = 0;
  double totalRevenue = 0;
  double accessoriesRevenue = 0;
  double approvalRate = 0;
  double averageOrderValue = 0;

  int? selectedMonth;
  int? selectedYear;
  bool isAllTime = true;

  final List<String> months = const [
    "Jan","Feb","Mar","Apr","May","Jun",
    "Jul","Aug","Sep","Oct","Nov","Dec"
  ];

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }


  void fetchAnalytics() {
    bookingsRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final users = event.snapshot.value as Map<dynamic, dynamic>;

      int approved = 0, pending = 0, rejected = 0, total = 0;
      double revenue = 0, accessories = 0;

      users.forEach((_, userBookings) {
        if (userBookings is Map) {
          userBookings.forEach((_, bookingData) {
            if (bookingData is! Map || bookingData["timestamp"] == null) return;

            DateTime bookingDate;
            try {
              bookingDate = DateTime.parse(bookingData["timestamp"]);
            } catch (_) {
              return;
            }


            if (!isAllTime) {
              if (selectedMonth != null &&
                  bookingDate.month != selectedMonth) return;
              if (selectedYear != null &&
                  bookingDate.year != selectedYear) return;
            }

            total++;
            final status =
                bookingData["status"]?.toString().toLowerCase() ?? "pending";

            if (status == "approved") {
              approved++;

              revenue += double.tryParse(
                  bookingData["finalPrice"]?.toString() ?? "0") ??
                  0;

              if (bookingData["accessories"] is List) {
                for (var acc in bookingData["accessories"]) {
                  if (acc is Map) {
                    accessories += double.tryParse(
                        acc["price"]?.toString() ?? "0") ??
                        0;
                  }
                }
              }
            } else if (status == "rejected") {
              rejected++;
            } else {
              pending++;
            }
          });
        }
      });

      final totalApprovedRevenue = revenue + accessories;

      setState(() {
        totalOrders = total;
        approvedOrders = approved;
        pendingOrders = pending;
        rejectedOrders = rejected;
        totalRevenue = revenue;
        accessoriesRevenue = accessories;

        averageOrderValue =
        approved > 0 ? totalApprovedRevenue / approved : 0;

        approvalRate =
        totalOrders > 0 ? (approvedOrders / totalOrders) * 100 : 0;
      });
    });
  }


  Widget _buildFilterRow() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ChoiceChip(
              label: const Text("All Time"),
              selected: isAllTime,
              onSelected: (_) {
                setState(() {
                  isAllTime = true;
                  selectedMonth = null;
                  selectedYear = null;
                });
                fetchAnalytics();
              },
            ),
            const SizedBox(width: 10),

            DropdownButton<int>(
              hint: const Text("Month"),
              value: selectedMonth,
              items: List.generate(
                12,
                    (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(months[i]),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  selectedMonth = val;
                  isAllTime = false;
                });
                fetchAnalytics();
              },
            ),

            const SizedBox(width: 10),

            DropdownButton<int>(
              hint: const Text("Year"),
              value: selectedYear,
              items: List.generate(
                5,
                    (i) {
                  int year = DateTime.now().year - i;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                },
              ),
              onChanged: (val) {
                setState(() {
                  selectedYear = val;
                  isAllTime = false;
                });
                fetchAnalytics();
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRevenueBarChart() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: _calculateMaxY(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => ColorSys.purple1,
                tooltipRoundedRadius: 12,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    "₹${rod.toY.toStringAsFixed(0)}",
                    const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            barGroups: [
              BarChartGroupData(x: 0, barRods: [
                BarChartRodData(
                    toY: totalRevenue,
                    color: Colors.deepPurple,
                    width: 24)
              ]),
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(
                    toY: accessoriesRevenue,
                    color: Colors.teal,
                    width: 24)
              ]),
            ],
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: _calculateInterval(_calculateMaxY()),
                  getTitlesWidget: (value, _) {
                    return Text(
                      formatRevenue(value),
                      style: const TextStyle(fontSize: 11),
                    );
                  },
                ),
              ),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    if (value.toInt() == 0) return const Text("Car");
                    if (value.toInt() == 1) return const Text("Accessories");
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: true),
          ),
        ),
      ),
    );
  }

  String formatRevenue(double value) {
    if (value >= 10000000) {
      return "₹${(value / 10000000).toStringAsFixed(1)}Cr";
    } else if (value >= 100000) {
      return "₹${(value / 100000).toStringAsFixed(1)}L";
    } else if (value >= 1000) {
      return "₹${(value / 1000).toStringAsFixed(1)}K";
    }
    return "₹${value.toInt()}";
  }

  double _calculateMaxY() {
    final total = totalRevenue + accessoriesRevenue;
    if (total <= 1000) return 1000;
    if (total <= 5000) return 5000;
    if (total <= 10000) return 10000;
    return total * 1.2;
  }

  double _calculateInterval(double maxY) {
    return maxY / 4;
  }




  @override
  Widget build(BuildContext context) {
    final String titleText = isAllTime
        ? "Sales Analytics (All Time)"
        : "Sales Analytics "
        "(${selectedMonth != null ? months[selectedMonth! - 1] : ""} "
        "${selectedYear ?? ""})";

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
            title: Text(titleText,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFilterRow(),
          const SizedBox(height: 16),

          _gradientStatCard("Total Orders", "$totalOrders",
              Icons.shopping_cart, [Colors.blue, Colors.blueAccent]),

          _gradientStatCard("Approved Orders", "$approvedOrders",
              Icons.check_circle, [Colors.green, Colors.lightGreen]),

          _gradientStatCard(
              "Total Revenue",
              "₹${totalRevenue.toStringAsFixed(0)}",
              Icons.currency_rupee,
              [Colors.deepPurple, Colors.purpleAccent]),

          _gradientStatCard(
              "Accessories Revenue",
              "₹${accessoriesRevenue.toStringAsFixed(0)}",
              Icons.extension,
              [Colors.teal, Colors.cyan]),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                  child: _kpiCard(
                      "Approval Rate",
                      "${approvalRate.toStringAsFixed(1)}%",
                      Icons.check_circle,
                      Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _kpiCard(
                      "Avg Order Value",
                      "₹${averageOrderValue.toStringAsFixed(0)}",
                      Icons.currency_rupee,
                      Colors.purple)),
            ],
          ),

          const SizedBox(height: 20),

          const Text("Orders Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          SizedBox(
            height: 220,
            child: _OrdersPieChart(
                approved: approvedOrders,
                pending: pendingOrders,
                rejected: rejectedOrders),
          ),

          const SizedBox(height: 20),

          const Text("Revenue Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),
          SizedBox(height: 220, child: _buildRevenueBarChart()),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminDetailAnalytics(),
                ),
              );
            },
            icon: const Icon(Icons.analytics),
            label: const Text("View Detailed Analytics"),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorSys.purple1,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

        ],
      ),
    );
  }
}


class _OrdersPieChart extends StatelessWidget {
  final int approved;
  final int pending;
  final int rejected;

  const _OrdersPieChart(
      {required this.approved,
        required this.pending,
        required this.rejected});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(sections: [
        PieChartSectionData(
            value: approved.toDouble(),
            color: Colors.green,
            title: "Approved"),
        PieChartSectionData(
            value: pending.toDouble(),
            color: Colors.orange,
            title: "Pending"),
        PieChartSectionData(
            value: rejected.toDouble(),
            color: Colors.red,
            title: "Rejected"),
      ]),
    );
  }
}


Widget _gradientStatCard(
    String title, String value, IconData icon, List<Color> colors) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: colors.last),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
              const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ]),
      ],
    ),
  );
}

Widget _kpiCard(String title, String value, IconData icon, Color color) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: const TextStyle(fontSize: 13)),
      ]),
    ),
  );
}
