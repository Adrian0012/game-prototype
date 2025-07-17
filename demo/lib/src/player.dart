import 'dart:async';

import 'package:demo/src/colissions/colission_block.dart';
import 'package:demo/src/colissions/colissions_utils.dart';
import 'package:demo/src/colissions/custom_hitbox.dart';
import 'package:demo/src/enums/player_state.dart';
import 'package:demo/src/enums/walk_direction.dart';
import 'package:demo/src/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<DemoGame>, KeyboardHandler {
  Player({super.position});

  late final Vector2 startingPosition;

  late final SpriteAnimation walkUpAnimation;
  late final SpriteAnimation walkDownAnimation;
  late final SpriteAnimation walkLeftAnimation;
  late final SpriteAnimation walkRightAnimation;

  Vector2 velocity = Vector2.zero();
  double moveSpeed = 100.0;

  double horizontalMovement = 0.0;
  double verticalMovement = 0.0;

  WalkDirection lastWalkDirection = WalkDirection.down;

  CustomHitbox hitbox = const CustomHitbox(
    offsetX: 16,
    offsetY: 16,
    width: 14.0,
    height: 4.0,
  );

  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() {
    startingPosition = position;

    _loadAllAnimations();

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.offsetY),
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerPosition(dt);
    _checkHorizontalCollisions();
    _checkVerticalCollisions();
    super.update(dt);
  }

  void _updatePlayerState() {
    PlayerState playerState = switch (lastWalkDirection) {
      WalkDirection.down => PlayerState.walkDown,
      WalkDirection.up => PlayerState.walkUp,
      WalkDirection.left => PlayerState.walkLeft,
      WalkDirection.right => PlayerState.walkRight,
    };

    if (velocity.x > 0) {
      playerState = PlayerState.walkRight;
    }

    if (velocity.x < 0) {
      playerState = PlayerState.walkLeft;
    }

    if (velocity.y < 0) {
      playerState = PlayerState.walkUp;
    }

    if (velocity.y > 0) {
      playerState = PlayerState.walkDown;
    }

    current = playerState;
  }

  void _updatePlayerPosition(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;

    velocity.y = verticalMovement * moveSpeed;
    position.y += velocity.y * dt;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0.0;
    verticalMovement = 0.0;

    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (!isLeftKeyPressed && !isRightKeyPressed) {
      final isUpKeyPressed =
          keysPressed.contains(LogicalKeyboardKey.keyW) ||
          keysPressed.contains(LogicalKeyboardKey.arrowUp);
      final isDownKeyPressed =
          keysPressed.contains(LogicalKeyboardKey.keyS) ||
          keysPressed.contains(LogicalKeyboardKey.arrowDown);

      verticalMovement += isUpKeyPressed ? -1 : 0;
      verticalMovement += isDownKeyPressed ? 1 : 0;

      if (verticalMovement > 0) {
        lastWalkDirection = WalkDirection.down;
      } else if (verticalMovement < 0) {
        lastWalkDirection = WalkDirection.up;
      }
    } else {
      horizontalMovement += isLeftKeyPressed ? -1 : 0;
      horizontalMovement += isRightKeyPressed ? 1 : 0;

      if (horizontalMovement > 0) {
        lastWalkDirection = WalkDirection.right;
      } else if (horizontalMovement < 0) {
        lastWalkDirection = WalkDirection.left;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    walkUpAnimation = _spriteAnimation(PlayerState.walkUp);
    walkDownAnimation = _spriteAnimation(PlayerState.walkDown);
    walkLeftAnimation = _spriteAnimation(PlayerState.walkLeft);
    walkRightAnimation = _spriteAnimation(PlayerState.walkRight);

    animations = {
      PlayerState.walkUp: walkUpAnimation,
      PlayerState.walkDown: walkDownAnimation,
      PlayerState.walkLeft: walkLeftAnimation,
      PlayerState.walkRight: walkRightAnimation,
    };

    current = PlayerState.walkDown;
  }

  SpriteAnimation _spriteAnimation(PlayerState state) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("player/${state.asset}.png"),
      SpriteAnimationData.sequenced(
        amount: state.frameCount,
        stepTime: 0.1,
        textureSize: Vector2.all(48.0),
      ),
    );
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (checkCollision(this, block)) {
        if (velocity.x > 0) {
          velocity.x = 0;
          position.x = block.x - hitbox.offsetX - hitbox.width;
          break;
        }
        if (velocity.x < 0) {
          velocity.x = 0;
          position.x = block.x + block.width - hitbox.offsetX;
        }
      }
    }
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (checkCollision(this, block)) {
        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = block.y - hitbox.height - hitbox.offsetY;
          break;
        }
        if (velocity.y < 0) {
          velocity.y = 0;
          position.y = block.y + block.height - hitbox.offsetY;
        }
      }
    }
  }
}
