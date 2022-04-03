import 'dart:async' as async;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flutter/material.dart';
import 'package:rpg_flame/components/bullets/mixins/weapon.dart';
import 'package:rpg_flame/components/bullets/plane_bullet.dart';
import 'package:rpg_flame/components/bullets/tank_bullet.dart';
import 'package:rpg_flame/components/shield.dart';
import 'package:rpg_flame/components/tank.dart';

import '../main.dart';

class Player extends SpriteComponent
    with HasGameRef, HasHitboxes, Collidable, Weapon {
  double maxSpeed = 150;

  final JoystickComponent joystick;
  final AudioPool pool;
  bool missionCleared = false;

  Player(this.joystick, this.pool) : super(size: Vector2(32, 24)) {
    addHitbox(HitboxRectangle());
    anchor = Anchor.center;
    angle = pi / 2;
    health = 20;
  }

  addPowerUps() async {
    var planes = await Flame.images.load('ships_packed.png');

    add(SpriteComponent(
        sprite: Sprite(planes,
            srcSize: Vector2(24, 29), srcPosition: Vector2(4, 39)),
        priority: 2)
      ..position = Vector2(-28, 4));
    add(SpriteComponent(
        sprite: Sprite(planes,
            srcSize: Vector2(24, 29), srcPosition: Vector2(4, 39)),
        priority: 2)
      ..position = Vector2(36, 4));
  }

  addShield() {
    add(Shield(
        radius: 35,
        paint: Paint()..color = Colors.lightBlueAccent.withAlpha(100))
      ..position = Vector2(15, 15));
    add(
      CircleComponent(
          position: Vector2(15, 15),
          anchor: Anchor.center,
          radius: 20,
          paint: Paint()
            ..color = Colors.purple.withAlpha(30)
            ..strokeWidth = 6
            ..style = PaintingStyle.stroke),
    );
    add(
      CircleComponent(
          position: Vector2(15, 15),
          anchor: Anchor.center,
          radius: 22,
          paint: Paint()
            ..color = Colors.orangeAccent.withAlpha(120)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke),
    );
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    var planes = await gameRef.images.load('ships_packed.png');
    var pool =
        await AudioPool.create('laser.mp3', minPlayers: 1, maxPlayers: 1);

    sprite =
        Sprite(planes, srcPosition: Vector2(0, 4), srcSize: Vector2(32, 24));
    position = gameRef.size / 2;
    timer = async.Timer.periodic(const Duration(milliseconds: 500), (timer) {
      pool.start(volume: 0.2);
      gameRef.add(PlaneBullet(this)
        ..position = Vector2(x, y)
        ..scale = Vector2(1, 1.5)
        ..add(
          ColorEffect(
            Colors.deepOrange.withAlpha(100),
            const Offset(0.0, 0.5),
            EffectController(curve: Curves.linear, duration: 0.5),
          ),
        ));

      if (children.any((element) => element is SpriteComponent)) {
        gameRef.add(PlaneBullet(this)
          ..position = Vector2(x, y - 30)
          ..add(
            ColorEffect(
              Colors.blueAccent.withAlpha(200),
              const Offset(0.0, 0.5),
              EffectController(
                  curve: Curves.fastLinearToSlowEaseIn, duration: 0.5),
            ),
          ));

        gameRef.add(PlaneBullet(this)
          ..position = Vector2(x, y + 30)
          ..add(
            ColorEffect(
              Colors.blueAccent.withAlpha(200),
              const Offset(0.0, 0.5),
              EffectController(
                  curve: Curves.fastLinearToSlowEaseIn, duration: 0.5),
            ),
          ));
      }
    });
  }

  @override
  void update(double dt) {
    if (!joystick.delta.isZero()) {
      var vector2 = joystick.relativeDelta * maxSpeed * dt;
      var x = vector2.x;
      var y = vector2.y;
      if ((this.x + x) > viewPortWidth - width / 2) {
        vector2.x = 0;
      }
      if ((this.x + x - width / 2) < 0) {
        vector2.x = 0;
      }
      if (this.y + y - height / 2 < 0) {
        vector2.y = 0;
      }
      if (this.y + y + height / 2 > 320) {
        vector2.y = 0;
      }
      position.add(vector2);
    }

    if (!gameRef.children.any((element) => element is Tank)) {
      if (!missionCleared) {
        (gameRef as IFRpgGame).missionCleared();
        add(MoveEffect.to(
          Vector2(viewPortWidth / 2, viewPortHeight / 2),
          EffectController(
              duration: 1,
              reverseDuration: 1,
              repeatCount: 3,
              curve: Curves.easeInCubic),
        ));
        missionCleared = true;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) async {
    super.onCollision(intersectionPoints, other);
    if (other is TankBullet) {
      health -= other.damage;
      if (health <= 0) {
        pool.start(volume: 0.8);
        gameRef.remove(this);
        timer.cancel();
        (gameRef as IFRpgGame).gameOver();
      }
      add(ColorEffect(
          Colors.red.withAlpha(130),
          const Offset(0.1, 0.5),
          EffectController(
              duration: 0.5, infinite: false, reverseDuration: 0.5)));
    }
  }
}
