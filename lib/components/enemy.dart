import 'package:esense/gameController.dart';
import 'package:flame/anchor.dart';
import 'dart:math';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';


class Enemy extends PositionComponent {
  GameController gameController;
  double speed;
  Offset direction = Offset(0,0);
  Rect enemyRect; // Offset.zero
  Sprite bgSprite;
  Random rand = Random();

  // game datamodel
  int damage = 1;
  bool isDead = false;

  Enemy(GameController controller, double size) {
    this.gameController = controller;
    //width = height = size;
    //
    speed = size * 2;
    width = height = size;
    Offset randomPosition = this.getRandPosition();
    enemyRect = Rect.fromLTWH(
      randomPosition.dx,
      randomPosition.dy,
      size,
      size,
    );
    anchor = Anchor.center;
    bgSprite = Sprite('zombie.png');
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    bgSprite.renderRect(c, Rect.fromLTWH(0, 0, width, height));
  }

  @override
  void update(double t) {
    if (!isDead) {
      double stepDistance = speed * t;
      Rect playerRect = gameController.player.playerRect;
      Offset toPlayer =
          playerRect.center - enemyRect.center;
      if (stepDistance <= toPlayer.distance - this.enemyRect.width * 1.25) {
        Offset stepToPlayer =
            Offset.fromDirection(toPlayer.direction, stepDistance);
        
        this.angle = atan2(enemyRect.center.dx - playerRect.center.dx, playerRect.center.dy - enemyRect.center.dy);
        enemyRect = enemyRect.shift(stepToPlayer);
        this.x = enemyRect.center.dx;
        this.y = enemyRect.center.dy;
      } else {
        attack();
      }
    }
  }


  void attack() {
    if (!gameController.player.isDead) {
      gameController.player.currentHealth -= damage;
    }
  }


  Offset getRandPosition() {
    double x, y;
    switch (rand.nextInt(4)) {
      case 0:
        // Top
        x = rand.nextDouble() * gameController.screenSize.width;
        y = -this.height * 2.5;
        break;
      case 1:
        // Right
        x = gameController.screenSize.width + this.height * 2.5;
        y = rand.nextDouble() * gameController.screenSize.height;
        break;
      case 2:
        // Bottom
        x = rand.nextDouble() * gameController.screenSize.width;
        y = gameController.screenSize.height + this.height * 2.5;
        break;
      case 3:
        // Left
        x = -this.height * 2.5;
        y = rand.nextDouble() * gameController.screenSize.height;
        break;
    }
    return Offset(x, y);
  }
}