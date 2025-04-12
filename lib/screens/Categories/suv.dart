import 'package:flutter/material.dart';

class SuvScreen extends StatelessWidget {
  const SuvScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SUV')),
      body: const Center(child: Text('SUV Page Content')),
    );
  }
}
