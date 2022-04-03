import 'dart:math';

import 'package:flame/components.dart';

mixin Bullets on SpriteComponent {
  late int damage;

  moveAlongLine(Vector2 source, Vector2 target, double speed) {
    var v = target.y - source.y;
    var h = target.x - source.x;
    var tangent = (h / v).abs();
    if (tangent < 1) {
      position.add(Vector2(h.sign * tangent, v.sign) * speed);
    } else {
      position.add(Vector2(h.sign, v.sign / tangent) * speed);
    }
  }

  moveWithAngle(num radians, double speed) {
    var abs = tan(radians).abs();
    double xSign = 1;
    double ySign = 1;
    if (radians >= pi / 2 && radians <= pi) {
      xSign = 1;
      ySign = 1;
    } else if (radians >= 0 && radians <= pi / 2) {
      xSign = 1;
      ySign = -1;
    } else if (radians <= -pi / 2 && radians > -pi) {
      xSign = -1;
      ySign = 1;
    } else {
      xSign = -1;
      ySign = -1;
    }
    if (abs < 1) {
      position.add(Vector2(xSign * abs, ySign) * speed);
    } else {
      position.add(Vector2(xSign, ySign / abs) * speed);
    }
  }

  bool offScreen(Vector2 viewPortSize) {
    return x < 0 || x > viewPortSize.x || y < 0 || y > viewPortSize.y;
  }
}
