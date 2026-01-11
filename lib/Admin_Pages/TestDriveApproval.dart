import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import '../Assistance/ColorHelper.dart';

enum TestDriveFilter { all, pending, approved, rejected }

class AdminTestDriveApprovalScreen extends StatefulWidget {
  const AdminTestDriveApprovalScreen({Key? key}) : super(key: key);

  @override
  State<AdminTestDriveApprovalScreen> createState() =>
      _AdminTestDriveApprovalScreenState();
}

class _AdminTestDriveApprovalScreenState
    extends State<AdminTestDriveApprovalScreen> {
  final DatabaseReference _testDriveRef =
  FirebaseDatabase.instance.ref("testDrive");

  TestDriveFilter _currentFilter = TestDriveFilter.pending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: StreamBuilder(
        stream: _testDriveRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset(
                "images/Travel_app.json",
                width: 220,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return _buildEmptyState();
          }

          final Map<dynamic, dynamic> allData =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          List<Map<String, dynamic>> requests = [];

          allData.forEach((userId, bookings) {
            (bookings as Map).forEach((bookingId, details) {
              requests.add({
                "userId": userId,
                "bookingId": bookingId,
                ...Map<String, dynamic>.from(details),
              });
            });
          });

          requests.sort((a, b) => DateTime.parse(b['timestamp'])
              .compareTo(DateTime.parse(a['timestamp'])));

          final pending =
              requests.where((r) => r['status'] == 'pending').length;
          final approved =
              requests.where((r) => r['status'] == 'approved').length;
          final rejected =
              requests.where((r) => r['status'] == 'rejected').length;

          final filteredRequests = _currentFilter == TestDriveFilter.all
              ? requests
              : requests
              .where(
                  (r) => r['status'] == _currentFilter.name)
              .toList();

          return Column(
            children: [
              _buildSummaryRow(pending, approved, rejected),
              _buildFilterTabs(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredRequests.length,
                  itemBuilder: (_, index) =>
                      _buildRequestCard(filteredRequests[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------- APP BAR ----------------
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
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
            "Test Drive Approvals",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
    );
  }

  // ---------------- SUMMARY CHIPS ----------------
  Widget _buildSummaryRow(int pending, int approved, int rejected) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _summaryChip("Pending", pending, Colors.orange),
          _summaryChip("Approved", approved, Colors.green),
          _summaryChip("Rejected", rejected, Colors.red),
        ],
      ),
    );
  }

  Widget _summaryChip(String title, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(count.toString(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ---------------- FILTER TABS ----------------
  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: TestDriveFilter.values.map((filter) {
          final selected = _currentFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentFilter = filter),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                  selected ? ColorSys.purple1 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  filter.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                    selected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- REQUEST CARD ----------------
  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'] ?? "pending";

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: status == "pending" ? 10 : 4,
      shadowColor:
      status == "pending" ? Colors.orange : Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(request['carName'] ?? "Unknown Car",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Chip(
                label: Text(status.toUpperCase()),
                backgroundColor: status == "approved"
                    ? Colors.green.shade100
                    : status == "rejected"
                    ? Colors.red.shade100
                    : Colors.orange.shade100,
              ),
            ],
          ),
          const Divider(),
          _infoRow(Icons.person, request['userName']),
          _infoRow(Icons.email, request['userEmail']),
          _infoRow(Icons.phone, request['userPhone']),
          _infoRow(Icons.location_on, request['address']),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 6),
              Text(request['testDriveDate']),
              const SizedBox(width: 14),
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 6),
              Text(request['testDriveTime']),
            ],
          ),
          const SizedBox(height: 12),
          if (status == "pending")
            Row(
              children: [
                _actionButton("Approve", Colors.green,
                        () => _confirmAction(request, "approved")),
                const SizedBox(width: 10),
                _actionButton("Reject", Colors.red,
                        () => _confirmAction(request, "rejected")),
              ],
            )
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String? text) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Expanded(child: Text(text ?? "N/A")),
      ],
    );
  }

  Widget _actionButton(String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(title),
      ),
    );
  }

  // ---------------- CONFIRM ACTION ----------------
  void _confirmAction(Map<String, dynamic> request, String status) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${status.toUpperCase()} Test Drive"),
        content: Text("Are you sure you want to $status this request?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(
                  request['userId'], request['bookingId'], status);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Confirm"),
          )
        ],
      ),
    );
  }

  // ---------------- UPDATE STATUS ----------------
  Future<void> _updateStatus(
      String userId, String bookingId, String status) async {
    await _testDriveRef
        .child(userId)
        .child(bookingId)
        .update({"status": status});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Test Drive $status")),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("images/empty_box.json", width: 200),
          const SizedBox(height: 10),
          const Text("No test drive requests found"),
        ],
      ),
    );
  }
}
