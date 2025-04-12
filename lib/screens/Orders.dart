import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderedCarScreen extends StatefulWidget {
  const OrderedCarScreen({Key? key}) : super(key: key);

  @override
  _OrderedCarScreenState createState() => _OrderedCarScreenState();
}

class _OrderedCarScreenState extends State<OrderedCarScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  List<Map<dynamic, dynamic>> normalBookings = [];
  List<Map<dynamic, dynamic>> emiBookings = [];

  @override
  void initState() {
    super.initState();
    fetchAllBookings();
  }

  void fetchAllBookings() async {
    if (uid == null) return;

    // Fetch Normal Bookings
    final normalSnap = await _dbRef.child('bookings').child(uid!).get();
    if (normalSnap.exists) {
      final Map<dynamic, dynamic> data = normalSnap.value as Map;
      data.forEach((key, value) {
        normalBookings.add(value as Map);
      });
    }

    // Fetch EMI Bookings
    final emiSnap = await _dbRef.child('EMI_Bookings').child(uid!).get();
    if (emiSnap.exists) {
      final Map<dynamic, dynamic> data = emiSnap.value as Map;
      data.forEach((key, value) {
        emiBookings.add(value as Map);
      });
    }

    setState(() {});
  }

  Widget buildSection(String title, List<Map<dynamic, dynamic>> bookings, bool isEmi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        bookings.isEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text("No $title found."),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(booking['car_name'] ?? booking['carName'] ?? 'Unknown'),
                subtitle: isEmi
                    ? Text("EMI: ₹${booking['monthly_emi'] ?? '-'}\nTotal Payable: ₹${booking['total_amount_payable'] ?? '-'}")
                    : Text("Price: ₹${booking['price'] ?? '-'}\nAddress: ${booking['address'] ?? '-'}"),
              ),
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Goes back to previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildSection("Normal Bookings", normalBookings, false),
            buildSection("EMI Bookings", emiBookings, true),
          ],
        ),
      ),
    );
  }
}
