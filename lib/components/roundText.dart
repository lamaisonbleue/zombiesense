import 'package:esense/gameController.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class RoundText extends PositionComponent{
  final GameController gameController;
  TextPainter painter;
  Offset position;

  RoundText(this.gameController) {
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
    int round = gameController.round;
    painter.text = TextSpan(
      text: 'Round: $round',
      style: TextStyle(
        color: Colors.white,
        fontSize: 40.0,
      ),
    );
    painter.layout();
    position = Offset(
      (gameController.screenSize.width / 2) - (painter.width / 2),
      (gameController.screenSize.height * 0.1) - (painter.height / 2),
    );
  }
}
