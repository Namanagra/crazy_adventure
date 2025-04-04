import 'dart:async';

// import 'package:flame/camera.dart';
import 'package:crazy_adventure/Components/checkpoint.dart';
import 'package:crazy_adventure/Components/chicken.dart';
import 'package:crazy_adventure/Components/fruit.dart';
import 'package:crazy_adventure/Components/saw.dart';
import 'package:flame/components.dart';
// import 'package:flame/flame.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:crazy_adventure/Components/background_tile.dart';
import 'package:crazy_adventure/Components/collision_block.dart';
import 'package:crazy_adventure/Components/player.dart';
import 'package:crazy_adventure/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoints in spawnPointsLayer.objects) {
        switch (spawnPoints.class_) {
          case 'Player':
            player.position = Vector2(spawnPoints.x, spawnPoints.y);
            player.scale.x = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoints.name,
              position: Vector2(spawnPoints.x, spawnPoints.y),
              size: Vector2(spawnPoints.width, spawnPoints.height),
            );
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoints.properties.getValue('isVertical');
            final offNeg = spawnPoints.properties.getValue('offNeg');
            final offPos = spawnPoints.properties.getValue('offPos');
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoints.x, spawnPoints.y),
              size: Vector2(spawnPoints.width, spawnPoints.height),
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoints.x, spawnPoints.y),
              size: Vector2(spawnPoints.width, spawnPoints.height),
            );
            add(checkpoint);
            break;
          case 'Chicken':
            final offNeg = spawnPoints.properties.getValue('offNeg');
            final offPos = spawnPoints.properties.getValue('offPos');
            final chicken = Chicken(
              position: Vector2(spawnPoints.x, spawnPoints.y),
              size: Vector2(spawnPoints.width, spawnPoints.height),
              offNeg: offNeg,
              offPos: offPos,
            );
            add(chicken);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
