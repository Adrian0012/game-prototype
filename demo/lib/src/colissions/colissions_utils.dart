import 'package:demo/src/colissions/colission_block.dart';
import 'package:demo/src/player.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  return (playerY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      playerX < blockX + blockWidth &&
      playerX + playerWidth > blockX);
}
