import 'dart:async';

import 'package:esense/accelerometerListener.dart';
import 'package:esense/components/background.dart';
import 'package:esense/components/enemy.dart';
import 'package:esense/components/gameOver.dart';
import 'package:esense/components/healthBar.dart';
import 'package:esense/components/roundText.dart';
import 'package:esense/components/player.dart';
import 'package:esense/main.dart';
import 'package:esense_flutter/esense.dart';
import 'package:flame/flame.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameController extends BaseGame {
  Size screenSize = Size.square(0);
  AccelerometerChangeListener accel;
  StreamSubscription sensorSubscription;
  
  Player player;
  GameOver gameOverScreen;
  // game attributes
  int round = 0;
  int enemySpawnTimer = 200;
  bool startedGame = false;

  GameController(AccelerometerChangeListener a)  {
    this.accel = a;
    init();
  }

  void init() async {
    this.screenSize = await Flame.util.initialDimensions();

    add(Background(this));
    add(HealthBar(this));
    add(RoundText(this));

    gameOverScreen = GameOver(this);
    add(gameOverScreen);

    this.player = Player(this, this.screenSize.width / 10, true);
    add(this.player);

    this.startListenToSensorEvents();
  }

 void startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    sensorSubscription = ESenseManager.sensorEvents.listen((event) {
        if (!this.startedGame) {                  
          startedGame = true;
          this.spawnEnemies();
        }else {
          this.accel.setAccl(event.accel);
          this.player.moveByAccelerometer(this.accel);
        }
    });
  }


  void spawnEnemies() {
    for (var i = 0; i < round+1; i++) {      
      final enemy = Enemy(this, this.screenSize.width / 10);
      add(enemy);
    }
    this.round += this.startedGame ? 1 : 0;
  }

  void gameOver() {
    this.gameOverScreen.text = "GAME OVER";
    this.startedGame = false;
    Timer(Duration(seconds: 3), () => navigateToMenu());
  }

  void navigateToMenu() {
    this.sensorSubscription.cancel();
    mainMenuState.setBestRound(this.round);
    Navigator.of(mainMenuState.context).pop();
  }

@override
  void update(double t) {
    super.update(t);
    if (this.startedGame) {
      enemySpawnTimer -= 1;
      if (enemySpawnTimer <= 0) {
        enemySpawnTimer = 1000;
        this.spawnEnemies();
      }
    }
  }
}


