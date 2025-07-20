// pure_flutter_sprite_animation.dart
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;

class AnimationProperties {
  final String imagePath;
  final Size frameSize;
  final int frameCount;
  final Duration frameDuration;

  const AnimationProperties({
    required this.imagePath,
    required this.frameSize,
    required this.frameCount,
    required this.frameDuration,
  });

  // Add equality checks for didUpdateWidget to work correctly
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimationProperties &&
          runtimeType == other.runtimeType &&
          imagePath == other.imagePath &&
          frameSize == other.frameSize &&
          frameCount == other.frameCount &&
          frameDuration == other.frameDuration;

  @override
  int get hashCode =>
      imagePath.hashCode ^
      frameSize.hashCode ^
      frameCount.hashCode ^
      frameDuration.hashCode;
}
// Make sure to import the AnimationProperties class if it's in a separate file
// import 'package:your_app_name/widgets/animation_properties.dart';

// PureFlutterSpriteAnimation - A StatefulWidget to manage the animation state
class PureFlutterSpriteAnimation extends StatefulWidget {
  final AnimationProperties
  animationProperties; // New: Takes the animation properties
  final bool playing; // Whether the animation should be playing or stopped
  final Size displaySize; // The desired size to render the sprite on screen

  const PureFlutterSpriteAnimation({
    super.key,
    required this.animationProperties, // New: Required AnimationProperties object
    this.playing = true,
    required this.displaySize,
  });

  @override
  State<PureFlutterSpriteAnimation> createState() =>
      _PureFlutterSpriteAnimationState();
}

class _PureFlutterSpriteAnimationState extends State<PureFlutterSpriteAnimation>
    with SingleTickerProviderStateMixin {
  ui.Image? _spriteSheetImage;
  late AnimationController _controller;
  List<Rect> _frameRects = [];

  @override
  void initState() {
    super.initState();
    _loadSpriteSheet(); // Load the initial animation's sprite sheet

    // Initialize AnimationController using properties from widget.animationProperties
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds:
            widget.animationProperties.frameDuration.inMilliseconds *
            widget.animationProperties.frameCount,
      ),
    );

    _setAnimationPlayback(widget.playing);
  }

  void _setAnimationPlayback(bool isPlaying) {
    if (isPlaying) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  Future<void> _loadSpriteSheet() async {
    try {
      final ByteData data = await rootBundle.load(
        widget.animationProperties.imagePath,
      ); // Use widget.animationProperties.imagePath

      ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image image) {
        if (!mounted) return;

        _frameRects = _calculateFrameRects(
          image,
          widget.animationProperties.frameSize,
          widget.animationProperties.frameCount,
        ); // Use properties

        setState(() {
          _spriteSheetImage = image;
        });
      });
    } catch (e) {
      debugPrint('Error loading sprite sheet: $e');
      setState(() {
        _spriteSheetImage = null;
      });
    }
  }

  List<Rect> _calculateFrameRects(
    ui.Image image,
    Size frameSize,
    int frameCount,
  ) {
    List<Rect> rects = [];
    double currentX = 0;
    for (int i = 0; i < frameCount; i++) {
      rects.add(Rect.fromLTWH(currentX, 0, frameSize.width, frameSize.height));
      currentX += frameSize.width;
      if (currentX > image.width && i < frameCount - 1) {
        debugPrint(
          'Warning: Sprite sheet frames might extend beyond image width.',
        );
      }
    }
    return rects;
  }

  @override
  void didUpdateWidget(covariant PureFlutterSpriteAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the animation *definition* has changed
    if (widget.animationProperties != oldWidget.animationProperties) {
      // If the animation itself changes, we need to:
      // 1. Stop the old controller (though it's about to be reassigned)
      _controller.stop();
      // 2. Update the controller's duration for the new animation
      _controller.duration = Duration(
        milliseconds:
            widget.animationProperties.frameDuration.inMilliseconds *
            widget.animationProperties.frameCount,
      );
      // 3. Reload the new sprite sheet image
      _loadSpriteSheet();
      // 4. Reset the controller to the start and re-init playback
      _controller.value = 0.0; // Reset animation to start
      _setAnimationPlayback(
        widget.playing,
      ); // Re-init playback based on new state
    }
    // If only the playing state changes, update playback without reloading
    else if (widget.playing != oldWidget.playing) {
      _setAnimationPlayback(widget.playing);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_spriteSheetImage == null || _frameRects.isEmpty) {
      return SizedBox(
        width: widget.displaySize.width,
        height: widget.displaySize.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: widget.displaySize.width,
      height: widget.displaySize.height,
      child: CustomPaint(
        painter: _SpriteSheetPainter(
          spriteSheet: _spriteSheetImage!,
          frameRects: _frameRects,
          animation: _controller,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// _SpriteSheetPainter remains unchanged
class _SpriteSheetPainter extends CustomPainter {
  final ui.Image spriteSheet;
  final List<Rect> frameRects;
  final Animation<double> animation;

  _SpriteSheetPainter({
    required this.spriteSheet,
    required this.frameRects,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final int currentFrameIndex = (animation.value * frameRects.length)
        .floor()
        .clamp(0, frameRects.length - 1);
    final Rect srcRect = frameRects[currentFrameIndex];
    final Rect dstRect = Offset.zero & size;

    canvas.drawImageRect(spriteSheet, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(covariant _SpriteSheetPainter oldDelegate) {
    return oldDelegate.spriteSheet != spriteSheet ||
        oldDelegate.frameRects != frameRects ||
        oldDelegate.animation != animation;
  }
}
