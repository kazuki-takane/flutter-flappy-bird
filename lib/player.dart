import 'package:flutter/material.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            "assets/images/player.jpg",
            fit: BoxFit.fill,
          )),
    );
  }
}
