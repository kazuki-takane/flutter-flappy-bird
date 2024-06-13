import 'dart:async';

import 'package:flappy_bird/player.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool gameHasStarted = false;
  static double birdYAxis = 0;
  double initialHeight = birdYAxis;
  double height = 0;
  double time = 0;

  void jump() {
    time = 0;
    initialHeight = birdYAxis;
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      time += 0.05;
      height = -5 * time * time + 3 * time;

      setState(() {
        birdYAxis = initialHeight - height;
      });

      if (birdYAxis > 2) {
        timer.cancel();
        gameHasStarted = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                if (gameHasStarted) {
                  jump();
                } else {
                  print(birdYAxis);
                  startGame();
                }
              },
              child: AnimatedContainer(
                alignment: Alignment(0, birdYAxis),
                duration: Duration(milliseconds: 0),
                color: Colors.blue,
                child: Player(),
              ),
            )),
        Expanded(
          child: Container(
            color: Colors.green,
          ),
        ),
      ]),
    );
  }
}
