import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:rpg_flame/components/bullets/mixins/bullets.dart';
import 'package:rpg_flame/components/tank.dart';

import '../../main.dart';
import '../player.dart';

class PlaneBullet extends SpriteComponent
    with HasGameRef, HasHitboxes, Collidable, Bullets {
  double maxSpeed = 300;
  Player player;
  late double targetAngle;

  PlaneBullet(this.player)
      : super(size: Vector2(12, 14), anchor: Anchor.center) {
    targetAngle = player.angle;
    angle = player.angle;
    addHitbox(HitboxRectangle());
    damage = 2;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    var tiles = await Flame.images.load('tiles_packed.png');
    sprite =
        Sprite(tiles, srcSize: Vector2(12, 14), srcPosition: Vector2(18, 1));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (offScreen(viewPort)) {
      gameRef.remove(this);
    }
    moveWithAngle(targetAngle, maxSpeed * dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Tank) {
      gameRef.remove(this);
    }
  }
}
