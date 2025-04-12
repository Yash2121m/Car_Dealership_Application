import 'package:flutter/material.dart';

class OffroadScreen extends StatelessWidget {
  const OffroadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offroad')),
      body: const Center(child: Text('Offroad Page Content')),
    );
  }
}
