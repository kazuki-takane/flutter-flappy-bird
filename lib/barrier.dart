import 'package:flutter/material.dart';

class Barrier extends StatelessWidget {
  const Barrier({super.key, required this.length});

  final double length;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: length,
      decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(width: 10, color: Colors.green.shade800),
          borderRadius: BorderRadius.circular(15)),
    );
  }
}
