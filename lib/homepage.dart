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
  final GlobalKey _expandedKey = GlobalKey();
  double expandedHeight = 0.0;
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
    print("Expanded height: $expandedHeight");
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

  void startGame(BuildContext context) {
    gameHasStarted = true;
    gameTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      time += 0.05;
      height = -4 * time * time + 2 * time;

      setState(() {
        birdYAxis = initialHeight - height;

        // バリアを超えたらスコア追加
        print("barrier1x$barrier1x");
        if (barrier1x < -0.05 && !isClearBarrier1) {
          print("barrier1超えた");
          isClearBarrier1 = true;
          gameScore += 10;

          if (bestScore < gameScore) {
            bestScore = gameScore;
          }
        }
        if (barrier2x < -0.05 && !isClearBarrier2) {
          isClearBarrier2 = true;
          gameScore += 10;

          if (bestScore < gameScore) {
            bestScore = gameScore;
          }
        }

        // バリアを再配置
        if (barrier1x < -1.2) {
          barrier1x = barrierResetPos;
          isClearBarrier1 = false;
        } else {
          barrier1x = barrier1x - barrierMoveSpeed;
        }
        if (barrier2x < -1.2) {
          barrier2x = barrierResetPos;
          isClearBarrier2 = false;
        } else {
          barrier2x = barrier2x - barrierMoveSpeed;
        }
      });

      // バリア接触でもゲームオーバー
      if (-0.05 < barrier1x && barrier1x < 0.05) {
        if (_checkEnterBarrier1(expandedHeight)) {
          timer.cancel();
          gameHasStarted = false;
          resetGame();
          _showDialog(context);
        }
      }
      if (-0.05 < barrier2x && barrier2x < 0.05) {
        if (_checkEnterBarrier2(expandedHeight)) {
          timer.cancel();
          gameHasStarted = false;
          resetGame();
          _showDialog(context);
        }
      }

      // 落下判定
      if (birdYAxis > 2) {
        timer.cancel();
        gameHasStarted = false;
        resetGame();
        _showDialog(context);
      }
    });
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
                Text('SCORE',
                    style: TextStyle(color: Colors.black, fontSize: 15)),
                SizedBox(height: 20),
                Text(gameScore.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 35)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      gameScore = 0;
                    });
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
                    duration: Duration(milliseconds: 0),
                    child: Barrier(
                      length: barrier1UpperLength,
                    )),
                AnimatedContainer(
                    alignment: Alignment(barrier1x, 1.1),
                    duration: Duration(milliseconds: 0),
                    child: Barrier(
                      length: barrier1LowerLength,
                    )),
                AnimatedContainer(
                    alignment: Alignment(barrier2x, -1.1),
                    duration: Duration(milliseconds: 0),
                    child: Barrier(
                      length: barrier2UpperLength,
                    )),
                AnimatedContainer(
                    alignment: Alignment(barrier2x, 1.1),
                    duration: Duration(milliseconds: 0),
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
                      Text(
                        "SCORE",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        gameScore.toString(),
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
                      Text(bestScore.toString(),
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
