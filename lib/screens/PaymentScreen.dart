import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Assistance/ColorHelper.dart';
import 'PaymentRecieptScreen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<dynamic, dynamic> bookingData;
  final int amount;
  final String bookingId;

  const PaymentScreen({
    Key? key,
    required this.bookingData,
    required this.amount,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  final user = FirebaseAuth.instance.currentUser;
  String userEmail = '';
  String userPhone = '';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getUserDetails();
  }

  void getUserDetails() async {
    if (user != null) {
      final snapshot = await FirebaseDatabase.instance.ref().child("users").child(user!.uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as dynamic);
        setState(() {
          userEmail = data['email'] ?? '';
          userPhone = data['phone'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_SVnQ4iUSyv0F1x',
      'amount': widget.amount,
      'name': 'Car Dealership',
      'description': 'Payment for Car Booking',
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
      },
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Payment Successful! ID: ${response.paymentId}")),
    );

    final bookingId = widget.bookingId;
    final userId = user!.uid;
    final timestamp = DateTime.now().toIso8601String();


    DatabaseReference bookingRef = FirebaseDatabase.instance
        .ref()
        .child("bookings")
        .child(userId)
        .child(bookingId);

    await bookingRef.update({
      "paymentDone": true,
      "paymentId": response.paymentId,
      "paymentTimestamp": timestamp,
    });


    Navigator.pop(context, true);


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentReceiptScreen(
          receiptData: {
            "bookingId": bookingId,
            "carName": widget.bookingData['carName'],
            "email": userEmail,
            "amountPaid": widget.amount ~/ 100,
            "paymentTimestamp": timestamp,
          },
        ),
      ),
    );
  }


  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ Payment Failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("💼 Wallet Selected: ${response.walletName}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorSys.purple1, ColorSys.purple2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: AppBar(
            title: const Text("Secure Payment",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorSys.purple1, ColorSys.purple2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.shade100,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payment, size: 60, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  "Pay for your Booking",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.bookingData['carName'] ?? 'Car Name',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Amount: ₹${widget.amount ~/ 100}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (userEmail.isNotEmpty && userPhone.isNotEmpty) {
                      openCheckout();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User details not loaded yet')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[200],
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: Colors.deepPurple,
                  ),
                  child: const Text(
                    "Pay Now",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
