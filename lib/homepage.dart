import 'dart:async';

import 'package:flappy_bird/barrier.dart';
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
  static double barrier1x = 1.5;
  double barrier2x = barrier1x + 1.5;

  void jump() {
    time = 0;
    initialHeight = birdYAxis;
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      time += 0.05;
      height = -4 * time * time + 2 * time;

      setState(() {
        birdYAxis = initialHeight - height;

        if (barrier1x < -1.2) {
          barrier1x = 1.5;
        } else {
          barrier1x -= 0.05;
        }
        if (barrier2x < -1.2) {
          barrier2x = 1.5;
        } else {
          barrier2x -= 0.05;
        }
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
      body: GestureDetector(
        onTap: () {
          if (gameHasStarted) {
            jump();
          } else {
            print(birdYAxis);
            startGame();
          }
        },
        child: Column(children: [
          Expanded(
              flex: 2,
              child: Stack(children: [
                AnimatedContainer(
                  alignment: Alignment(0, birdYAxis),
                  duration: const Duration(milliseconds: 0),
                  color: Colors.blue,
                  child: const Player(),
                ),
                Container(
                    alignment: const Alignment(0, -0.3),
                    child: gameHasStarted
                        ? const Text("")
                        : const Text(
                            "T A P  T O  P L A Y",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )),
                AnimatedContainer(
                    alignment: Alignment(barrier1x, 1.1),
                    duration: Duration(milliseconds: 0),
                    child: Barrier(
                      length: 100,
                    )),
                AnimatedContainer(
                    alignment: Alignment(barrier1x, -1.1),
                    duration: Duration(milliseconds: 0),
                    child: Barrier(
                      length: 150,
                    )),
                AnimatedContainer(
                    alignment: Alignment(barrier2x, 1.1),
                    duration: Duration(milliseconds: 0),
                    child: Barrier(
                      length: 150,
                    )),
                AnimatedContainer(
                    alignment: Alignment(barrier2x, -1.1),
                    duration: Duration(milliseconds: 0),
                    child: Barrier(
                      length: 100,
                    ))
              ])),
          Container(
            height: 15,
            color: Colors.green,
          ),
          Expanded(
            child: Container(
              color: Colors.brown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "SCORE",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        "0",
                        style: TextStyle(color: Colors.white, fontSize: 35),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "BEST",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text("10",
                          style: TextStyle(color: Colors.white, fontSize: 35))
                    ],
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
