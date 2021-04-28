// GameOverScreen

import 'package:esense/gameController.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class GameOver extends PositionComponent{
  final GameController gameController;
  TextPainter painter;
  Offset position;
  String text = "";

  GameOver(this.gameController) {
    painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    position = Offset.zero;
  }

  void render(Canvas c) {
    painter.paint(c, position);
  }

  void update(double t) {
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 50.0,
      ),
    );
    painter.layout();
    position = Offset(
      (gameController.screenSize.width / 2) - (painter.width / 2),
      (gameController.screenSize.height * 0.5) - (painter.height / 2),
    );
  }
}
