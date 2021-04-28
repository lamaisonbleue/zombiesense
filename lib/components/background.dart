import 'package:esense/gameController.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Background extends PositionComponent {
  GameController gameController;
  Sprite bgSprite;

  // game model attributes
  int maxHealth = 300;
  int currentHealth = 300;
  double speed = 1;
  bool isDead = false;

  Background(GameController controller) {
    this.gameController = controller;
    anchor = Anchor.topLeft;
    width = gameController.screenSize.width;
    height = gameController.screenSize.height * 2;
    y = -0.5 * height;
    bgSprite = Sprite('background2.png');

  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    bgSprite.renderRect(c, Rect.fromLTWH(0, 0, width, height));
  }

  @override
  void update(double t) {
    if (this.toRect().top > 0) {
      this.y -= 0.5 * height;
    }else {
      this.y += 1;
    }   
  }

}