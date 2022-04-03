import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/cupertino.dart';
import 'package:rpg_flame/components/bullets/tank_bullet.dart';

class Shield extends CircleComponent with HasGameRef, Collidable {
  Shield({required double radius, required Paint paint})
      : super(radius: radius, paint: paint) {
    anchor = Anchor.center;
    addHitbox(HitboxCircle(size: Vector2(radius, radius)));
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is TankBullet) {
      gameRef.remove(other);
    }
  }
}
