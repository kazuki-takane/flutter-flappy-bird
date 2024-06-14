import 'dart:async';
import 'dart:math';

import 'package:flappy_bird/barrier.dart';
import 'package:flappy_bird/player.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double barrierResetPos = 1.5;
  static const double barrierMoveSpeed = 0.05;

  bool gameHasStarted = false;
  double birdYAxis = 0;
  double initialHeight = 0;
  double height = 0;
  double time = 0;
  static double barrier1x = 1.5;
  double barrier2x = barrier1x + 1.5;
  Timer? gameTimer;
  final GlobalKey _expandedKey = GlobalKey();
  double expandedHeight = 0;
  double barrier1UpperLength = 100;
  double barrier1LowerLength = 150;
  double barrier2UpperLength = 150;
  double barrier2LowerLength = 100;
  bool isClearBarrier1 = false;
  bool isClearBarrier2 = false;
  double gameScore = 0;
  static double bestScore = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback(_getHeight);
  }

  void _getHeight(Duration timeStamp) {
    final RenderBox renderBox =
        _expandedKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      expandedHeight = renderBox.size.height;
    });
  }

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
    isClearBarrier1 = false;
    isClearBarrier2 = false;
  }

  void updateScore() {
    if (barrier1x < -0.05 && !isClearBarrier1) {
      isClearBarrier1 = true;
      gameScore += 10;
      updateBestScore();
    }
    if (barrier2x < -0.05 && !isClearBarrier2) {
      isClearBarrier2 = true;
      gameScore += 10;
      updateBestScore();
    }
  }

  void updateBestScore() {
    if (bestScore < gameScore) {
      bestScore = gameScore;
    }
  }

  void randomizeBarrier1Length() {
    barrier1UpperLength =
        Random().nextInt(57) * expandedHeight / 100 + expandedHeight * 0.1;
    barrier1LowerLength =
        expandedHeight - expandedHeight * 0.33 - barrier1UpperLength;
  }

  void randomizeBarrier2Length() {
    barrier2UpperLength =
        Random().nextInt(57) * expandedHeight / 100 + expandedHeight * 0.1;
    barrier2LowerLength =
        expandedHeight - expandedHeight * 0.33 - barrier2UpperLength;
  }

  void relocationBarriers() {
    if (barrier1x < -1.2) {
      barrier1x = barrierResetPos;
      randomizeBarrier1Length();
      isClearBarrier1 = false;
    } else {
      barrier1x -= barrierMoveSpeed;
    }
    if (barrier2x < -1.2) {
      barrier2x = barrierResetPos;
      randomizeBarrier2Length();
      isClearBarrier2 = false;
    } else {
      barrier2x -= barrierMoveSpeed;
    }
  }

  bool checkCollisionBarrier(barrier1x, barrier2x, expandedHeight) {
    return (-0.05 < barrier1x &&
            barrier1x < 0.05 &&
            _checkEnterBarrier1(expandedHeight)) ||
        -0.05 < barrier2x &&
            barrier2x < 0.05 &&
            _checkEnterBarrier2(expandedHeight);
  }

  // バリア接触判定
  bool _checkEnterBarrier1(double expandedHeight) {
    final double playerHeight = expandedHeight * (1 - birdYAxis) / 2;
    final double barrier1UpperPos = expandedHeight - barrier1UpperLength;
    final double barrier1LowerPos = barrier1LowerLength;

    return playerHeight > barrier1UpperPos || playerHeight < barrier1LowerPos;
  }

  bool _checkEnterBarrier2(double expandedHeight) {
    final double playerHeight = expandedHeight * (1 - birdYAxis) / 2;
    final double barrier2UpperPos = expandedHeight - barrier2UpperLength;
    final double barrier2LowerPos = barrier2LowerLength;

    return playerHeight > barrier2UpperPos || playerHeight < barrier2LowerPos;
  }

  void startGame(BuildContext context) {
    gameHasStarted = true;
    gameTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      time += 0.05;
      height = -4 * time * time + 2 * time;

      setState(() {
        birdYAxis = initialHeight - height;
        // バリアを超えたらスコア追加
        updateScore();
        // バリアを再配置
        relocationBarriers();
      });

      // バリア接触、落下でゲームオーバー
      if (checkCollisionBarrier(barrier1x, barrier2x, expandedHeight) ||
          birdYAxis > 2) {
        timer.cancel();
        gameHasStarted = false;
        resetGame();
        _showDialog(context);
      }
    });
  }

  // モーダル
  void _showDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('SCORE',
                    style: TextStyle(color: Colors.black, fontSize: 15)),
                const SizedBox(height: 20),
                Text(gameScore.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 35)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      gameScore = 0;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('RESTART'),
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
              key: _expandedKey,
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
                    alignment: Alignment(barrier1x, -1.1),
                    duration: const Duration(milliseconds: 0),
                    child: Barrier(
                      length: barrier1UpperLength,
                    )),
                AnimatedContainer(
                    alignment: Alignment(barrier1x, 1.1),
                    duration: const Duration(milliseconds: 0),
                    child: Barrier(
                      length: barrier1LowerLength,
                    )),
                AnimatedContainer(
                    alignment: Alignment(barrier2x, -1.1),
                    duration: const Duration(milliseconds: 0),
                    child: Barrier(
                      length: barrier2UpperLength,
                    )),
                AnimatedContainer(
                    alignment: Alignment(barrier2x, 1.1),
                    duration: const Duration(milliseconds: 0),
                    child: Barrier(
                      length: barrier2LowerLength,
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
                      const Text(
                        "SCORE",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        gameScore.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 35),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "BEST",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(bestScore.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 35))
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
