import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:rpg_flame/components/bullets/mixins/bullets.dart';
import 'package:rpg_flame/components/player.dart';
import 'package:rpg_flame/main.dart';

class TankBullet extends SpriteComponent
    with HasGameRef, HasHitboxes, Collidable, Bullets {
  double maxSpeed = 100;
  final Vector2 target;
  late Vector2 source;
  final Player player;

  TankBullet(this.player, this.target) : super(size: Vector2(8, 12)) {
    damage = 1;
    addHitbox(HitboxRectangle());
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    source = Vector2(x, y);
    var tiles = await Flame.images.load('tiles_packed.png');
    sprite =
        Sprite(tiles, srcSize: Vector2(8, 12), srcPosition: Vector2(4, 18));
  }

  @override
  void update(double dt) {
    super.update(dt);
    moveAlongLine(source, target, maxSpeed * dt);
    if (offScreen(viewPort)) {
      gameRef.remove(this);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      gameRef.remove(this);
    }
  }
}
