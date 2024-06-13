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
  double birdYAxis = 0;
  double initialHeight = 0;
  double height = 0;
  double time = 0;
  double barrierResetPos = 1.5;
  double barrierMoveSpeed = 0.05;
  static double barrier1x = 1.5;
  double barrier2x = barrier1x + 1.5;
  Timer? gameTimer;

  void jump() {
    time = 0;
    initialHeight = birdYAxis;
  }

  void resetGame() {
    birdYAxis = 0;
    initialHeight = 0;
    time = 0;
    barrier1x = barrierResetPos;
    barrier2x = barrierResetPos + 1.5;
  }

  void startGame(BuildContext context) {
    gameHasStarted = true;
    gameTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      time += 0.05;
      height = -4 * time * time + 2 * time;

      setState(() {
        birdYAxis = initialHeight - height;

        barrier1x =
            barrier1x < -1.2 ? barrierResetPos : barrier1x - barrierMoveSpeed;
        barrier2x =
            barrier2x < -1.2 ? barrierResetPos : barrier2x - barrierMoveSpeed;
      });

      if (birdYAxis > 2) {
        timer.cancel();
        gameHasStarted = false;
        resetGame();
        _showDialog(context);
      }
    });
  }

  void _showDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SCORE',
                    style: TextStyle(color: Colors.black, fontSize: 15)),
                SizedBox(height: 20),
                Text("10", style: TextStyle(color: Colors.black, fontSize: 35)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('RESTART'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (gameHasStarted) {
            jump();
          } else {
            startGame(context);
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
