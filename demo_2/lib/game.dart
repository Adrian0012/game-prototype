import 'package:demo_2/components/components.dart';
import 'package:demo_2/models/models.dart';
import 'package:demo_2/src/custom_animation.dart';
import 'package:flame/game.dart' show Vector2;
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'data/data.dart';

class DemoGame extends StatefulWidget {
  const DemoGame({super.key});

  @override
  State<DemoGame> createState() => _DemoGameState();
}

class _DemoGameState extends State<DemoGame>
    with SingleTickerProviderStateMixin {
  static const double svgNaturalWidth = 2000.0;
  static const double svgNaturalHeight = 2000.0;
  final TransformationController _transformationController =
      TransformationController();
  double _currentWarriorX = 762.0;
  double _currentWarriorY = 733.0;

  late AnimationController _moveAnimationController;
  late Animation<Offset> _moveAnimation;
  bool _isWalking = false;
  OverlayEntry? _currentOverlayEntry;

  void _showPoiPopupMenu(PointOfInterest point, GlobalKey poiKey) {
    // Get the RenderBox of the tapped PointOfInterestWidget
    final RenderBox renderBox =
        poiKey.currentContext!.findRenderObject() as RenderBox;

    // Get the global position of the top-left corner of the widget
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Calculate the center of the POI widget in global coordinates
    final double centerX = offset.dx + PointOfInterestWidget.markerSize / 2;
    final double centerY = offset.dy + PointOfInterestWidget.markerSize / 2;

    // Remove any existing overlay before showing a new one
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;

    _currentOverlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // This GestureDetector captures taps outside the menu to dismiss it
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _currentOverlayEntry?.remove();
                _currentOverlayEntry = null;
              },
              // Make sure it's absorbPointer to prevent interaction with elements below
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            // Position the menu slightly above and centered on the POI
            left: centerX - 150 / 2, // Assuming menu width is 150
            top:
                centerY -
                (MediaQuery.of(context).size.height * 0.27) -
                PointOfInterestWidget.markerSize / 2,
            child: Material(
              color: Colors.transparent, // Important for shadow
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SizedBox(
                  width: 150, // Fixed width for the menu
                  child: PointOfInterestCardMenu(
                    point: point,
                    onDismiss: () {
                      _currentOverlayEntry?.remove();
                      _currentOverlayEntry = null;
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_currentOverlayEntry!);
  }

  void _handleTap(PointOfInterest point) {
    // print('Tapped on Point: ${point.label} at (${point.x}, ${point.y})');

    final Offset startPosition = _moveAnimationController.isAnimating
        ? _moveAnimation.value
        : Offset(_currentWarriorX, _currentWarriorY);

    if (_moveAnimationController.isAnimating) {
      _moveAnimationController.stop();
      print(
        'Animation interrupted. New start position for tween: $startPosition',
      );
    }

    // Define the new animation tween
    _moveAnimation =
        Tween<Offset>(
          begin: startPosition,
          end: Offset(point.x, point.y),
        ).animate(
          CurvedAnimation(
            parent: _moveAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    _moveAnimationController.reset(); // Resets controller value to 0.0
    print(
      'Animation will start from: $startPosition to ${Offset(point.x, point.y)}',
    );

    // Start the animation and update _isWalking state
    setState(() {
      _isWalking = true; // Switch to walking animation
    });

    _moveAnimationController.forward().then((_) {
      // This runs when the animation completes
      setState(() {
        _currentWarriorX = point.x; // Ensure final resting position is exact
        _currentWarriorY = point.y;
        _isWalking = false; // Switch back to idle animation
        print(
          'Animation completed. Warrior final position: ($_currentWarriorX, $_currentWarriorY)',
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _moveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Initialize _moveAnimation. It starts and ends at the warrior's initial position.
    _moveAnimation = Tween<Offset>(
      begin: Offset(_currentWarriorX, _currentWarriorY),
      end: Offset(_currentWarriorX, _currentWarriorY),
    ).animate(_moveAnimationController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialView();
    });
  }

  void _setInitialView() {
    if (!mounted) return;

    final mediaQueryData = MediaQuery.of(context);
    final double availableWidth = mediaQueryData.size.width;
    final double availableHeight =
        mediaQueryData.size.height -
        kToolbarHeight -
        mediaQueryData.padding.top;

    const double desiredInitialScale = 0.7;
    final double initialScale = desiredInitialScale.clamp(0.1, 5.0);
    final double targetSvgX = svgNaturalWidth / 2;
    final double targetSvgY = svgNaturalHeight / 2;
    final double scaledTargetX = targetSvgX * initialScale;
    final double scaledTargetY = targetSvgY * initialScale;
    final double translateX = (availableWidth / 2) - scaledTargetX;
    final double translateY = (availableHeight / 2) - scaledTargetY;

    // Create the transformation matrix
    final Matrix4 initialMatrix = Matrix4.identity()
      ..translate(translateX, translateY)
      ..scale(initialScale);

    _transformationController.value = initialMatrix;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _moveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double warriorDisplaySize = 100;
    final AnimationProperties idleAnimationProperties =
        const AnimationProperties(
          imagePath: 'assets/images/warrior.png', // Different file for idle
          frameSize: Size(192.0, 192.0), // Example frame size
          frameCount: 5, // Example number of idle frames
          frameDuration: Duration(milliseconds: 90), // 10 frames per second
        );

    // Define the properties for your Walking animation
    final AnimationProperties walkAnimationProperties =
        const AnimationProperties(
          imagePath: 'assets/images/walk.png', // Different file for walking
          frameSize: Size(
            192.0,
            192.0,
          ), // Example frame size (should match actual frames)
          frameCount: 5, // Example number of walking frames
          frameDuration: Duration(
            milliseconds: 90,
          ), // Slightly faster for walking
        );

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            SpriteButton.asset(
              path: 'buttons.png',
              pressedPath: 'buttons.png',
              srcPosition: Vector2(0, 0),
              srcSize: Vector2(60, 20),
              pressedSrcPosition: Vector2(0, 20),
              pressedSrcSize: Vector2(60, 20),
              onPressed: () {},
              label: const Text(
                'Pew Pew',
                style: TextStyle(color: Color(0xFF5D275D)),
              ),
              width: 120,
              height: 75,
            ),
          ],
        ),
      ),
      body: InteractiveViewer(
        scaleEnabled: true,
        panEnabled: true,
        transformationController: _transformationController,
        onInteractionStart: (details) {},
        constrained: false,
        minScale: 0.5,
        maxScale: 2.5,
        child: SizedBox(
          width: svgNaturalWidth,
          height: svgNaturalHeight,
          child: Stack(
            children: [
              SvgPicture.asset(
                'assets/images/001__map.svg',
                placeholderBuilder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(30.0),
                  child: const CircularProgressIndicator(),
                ),
              ),
              AnimatedBuilder(
                animation: Listenable.merge([_moveAnimationController]),
                builder: (context, child) {
                  double displayX = _isWalking
                      ? _moveAnimation.value.dx
                      : _currentWarriorX;
                  double displayY = _isWalking
                      ? _moveAnimation.value.dy
                      : _currentWarriorY;

                  final AnimationProperties currentAnimationProperties =
                      _isWalking
                      ? walkAnimationProperties
                      : idleAnimationProperties;

                  return Positioned(
                    left: displayX - (warriorDisplaySize / 2),
                    top: displayY - (warriorDisplaySize / 2),
                    child: SizedBox(
                      width: warriorDisplaySize,
                      height: warriorDisplaySize,
                      // child: SpriteAnimationWidget.asset(
                      //   path: 'warrior.png',
                      //   data: _isWalking
                      //       ? _walkAnimationData
                      //       : _idleAnimationData,
                      //   playing: true,
                      //   anchor: Anchor.center,
                      // ),
                      child: PureFlutterSpriteAnimation(
                        animationProperties:
                            currentAnimationProperties, // Pass the chosen properties
                        playing:
                            true, // Animation should always be playing if the warrior is visible
                        displaySize: Size.square(
                          warriorDisplaySize,
                        ), // The size you want it to display at
                      ),
                    ),
                  );
                },
              ),
              ...gamePoi.map((point) {
                final double scaledX = point.x;
                final double scaledY = point.y;
                const double markerOffset =
                    PointOfInterestWidget.markerSize / 2;
                final GlobalKey poiKey = GlobalKey();
                return Positioned(
                  key: poiKey,
                  left: scaledX - markerOffset,
                  top: scaledY - markerOffset,
                  child: PointOfInterestWidget(
                    point: point,
                    // onTap: () => _handleTap(point),
                    onTap: () {
                      _showPoiPopupMenu(point, poiKey);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
