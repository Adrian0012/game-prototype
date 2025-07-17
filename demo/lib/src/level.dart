import 'dart:async';

import 'package:demo/src/colissions/colission_block.dart';
import 'package:demo/src/game.dart';
import 'package:demo/src/player.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameReference<DemoGame> {
  Level({required this.player});

  final Player player;

  late TiledComponent _map;
  List<CollisionBlock> collisionBlocks = [];

  @override
  Future<void> onLoad() async {
    _map = await TiledComponent.load('map.tmx', Vector2.all(32.0));

    add(_map);
    _spawnObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _spawnObjects() {
    final spawnPointLayer = _map.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
        }
      }
    }
  }

  void _addCollisions() {
    final collidersLayer = _map.tileMap.getLayer<ObjectGroup>(
      'CollisionBlocks',
    );

    if (collidersLayer != null) {
      for (final collider in collidersLayer.objects) {
        final block = CollisionBlock(
          position: Vector2(collider.x, collider.y),
          size: Vector2(collider.width, collider.y),
        );
        collisionBlocks.add(block);
        add(block);
      }

      player.collisionBlocks = collisionBlocks;
    }
  }
}
