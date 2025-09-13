import 'dart:typed_data';
import 'package:flutter/material.dart';

class FullImageScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final String label;

  const FullImageScreen({Key? key, required this.imageBytes, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}
