import 'dart:async' as async;

import 'package:flame/components.dart';

mixin Weapon on SpriteComponent {
  late int health;

  late async.Timer timer;
}
