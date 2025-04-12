import 'package:flutter/material.dart';

class SedanScreen extends StatelessWidget {
  const SedanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sedan')),
      body: const Center(child: Text('Sedan Page Content')),
    );
  }
}
