import 'package:esense/accelerometerListener.dart';
import 'package:esense/gameController.dart';
import 'package:esense/main.dart';
import 'package:flame/anchor.dart';
import 'dart:math';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  GameController gameController;
  final rotate;
  Offset direction = Offset(0,0);
  Rect playerRect;
  Sprite bgSprite;

  // game model attributes
  int maxHealth = 300;
  int currentHealth = 300;
  double speed = 1;
  bool isDead = false;

  Player(GameController controller, double size, this.rotate) {
    this.gameController = controller;
    playerRect = Rect.fromLTWH(
      gameController.screenSize.width / 2 - size / 2,
      gameController.screenSize.height / 2 - size / 2,
      size,
      size,
    );
    width = height = size;
    anchor = Anchor.center;
    bgSprite = Sprite('player.png');

  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    bgSprite.renderRect(c, Rect.fromLTWH(0, 0, width, height));
  }

  @override
  void update(double t) {
    // check if player is dead
    if (!isDead && currentHealth <= 0) {
      this.gameOver();
    }

    Size screenSize = gameController.screenSize;
    Rect newPosition = playerRect.shift(this.direction * 4);
    bool outOfScreen =  newPosition.left < 0 || newPosition.top < 0 || newPosition.bottom > screenSize.height || newPosition.right > screenSize.width;

    // rotate player to moving-direction
    this.angle = atan2(playerRect.center.dx - newPosition.center.dx, newPosition.center.dy - playerRect.center.dy);
    playerRect = outOfScreen ? playerRect : newPosition;
    
    // check if player is out of screen
    if (newPosition.left > 0 && newPosition.right < screenSize.width) {
      this.x = newPosition.center.dx;
    }
    if (newPosition.top > 0 && newPosition.bottom < screenSize.height) {
    this.y = newPosition.center.dy;
    }
  }

// need to be between -1 and 1
  void moveByAccelerometer(AccelerometerChangeListener accel) {
    this.direction = Offset(-accel.z, -accel.y);
  }


  void gameOver() {
    isDead = true;
    this.gameController.gameOver();    
  }
}