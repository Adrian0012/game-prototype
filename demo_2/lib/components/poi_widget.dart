import 'package:demo_2/models/models.dart';
import 'package:demo_2/src/custom_animation.dart';
import 'package:flutter/material.dart';

class PointOfInterestWidget extends StatelessWidget {
  const PointOfInterestWidget({
    super.key,
    required this.point,
    required this.onTap,
  });

  final PointOfInterest point;
  final VoidCallback onTap;
  static const double markerSize = 48.0;

  @override
  Widget build(BuildContext context) {
    AnimationProperties? animation;

    if (point.isAnimation) {
      animation = AnimationProperties(
        imagePath: point.asset,
        frameSize: Size(point.assetSizeX, point.assetSizeY),
        frameCount: point.frameCount,
        frameDuration: Duration(milliseconds: 120),
      );
    }
    return point.asset.isEmpty
        ? GestureDetector(
            onTap: onTap,
            child: Container(
              width: markerSize,
              height: markerSize,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              child: Center(
                child: Text(
                  // point.label,
                  '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Use a fixed font size
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        : point.isAnimation
        ? PureFlutterSpriteAnimation(
            animationProperties: animation!,
            playing: true,
            displaySize: Size.square(point.assetSize),
          )
        : GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: point.assetSize,
              height: point.assetSize,
              child: Image.asset(point.asset),
            ),
          );
  }
}
