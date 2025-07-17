import 'package:demo/src/level.dart';
import 'package:demo/src/player.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class DemoGame extends FlameGame with HasKeyboardHandlerComponents {
  DemoGame();

  late Level _level;
  late CameraComponent _camera;
  late Player player;

  @override
  Future<void> onLoad() async {
    await images.loadAllImages();
    player = Player();

    _loadLevel(player);

    return super.onLoad();
  }

  void _loadLevel(Player player) {
    _level = Level(player: player);

    final gameWidth = size.x;
    final gameHeight = size.y;

    _camera = CameraComponent(
      viewport: FixedSizeViewport(gameWidth, gameHeight),
      world: _level,
    );
    _camera.viewfinder.anchor = Anchor.center;
    _camera.viewfinder.zoom = 1.5;

    final x = (size.x - gameWidth) / 2;
    final y = (size.y - gameHeight) / 2;

    _camera.viewport.position = Vector2(x, y);

    _camera.follow(player);

    addAll([_camera, _level]);
  }

  void reload() {
    removeAll(children);
    onLoad();
  }
}
