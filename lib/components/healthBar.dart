import 'dart:ui';
import 'package:esense/gameController.dart';
import 'package:flame/components/component.dart';

class HealthBar extends PositionComponent{
  final GameController gameController;
  Rect healthBarRect;
  Rect remainingHealthRect;
  

  HealthBar(this.gameController) {
    double barWidth = gameController.screenSize.width / 1.75;
    final position = Offset(gameController.screenSize.width / 2 - barWidth / 2,
                            gameController.screenSize.height * 0.9);
  /*
    healthBarRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      barWidth,
      gameController.screenSize.width / 10 * 0.5,
    );
    remainingHealthRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      barWidth,
      gameController.screenSize.width / 10 * 0.5,
    );*/
    this.x = position.dx;
    this.y = position.dy;
    this.width = gameController.screenSize.width / 1.75;
    this.height = gameController.screenSize.width / 10 * 0.5;
    this.remainingHealthRect = this.toRect();
  }

  void render(Canvas c) {
    Paint healthBarColor = Paint()..color = Color(0xFFFF0000);
    Paint remainingBarColor = Paint()..color = Color(0xFF00FF00);
    c.drawRect(this.toRect(), healthBarColor);
    c.drawRect(this.remainingHealthRect, remainingBarColor);
  }

  void update(double t) {
    double barWidth = gameController.screenSize.width / 1.75;
    double percentHealth = gameController.player.currentHealth / gameController.player.maxHealth;
    remainingHealthRect = Rect.fromLTWH(
      this.x,
      this.y,
      barWidth * percentHealth,
      gameController.screenSize.width / 10 * 0.5,
    );
  }
}
