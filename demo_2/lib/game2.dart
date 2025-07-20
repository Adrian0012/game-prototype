import 'package:demo_2/models/models.dart';
import 'package:flame/game.dart' show Vector2;
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'components/components.dart';
import 'data/data.dart';

class DemoGame2 extends StatefulWidget {
  const DemoGame2({super.key});

  @override
  State<DemoGame2> createState() => _DemoGame2State();
}

class _DemoGame2State extends State<DemoGame2>
    with SingleTickerProviderStateMixin {
  static const double svgNaturalWidth = 2000.0;
  static const double svgNaturalHeight = 2000.0;

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                'assets/images/002__map.svg',
                placeholderBuilder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(30.0),
                  child: const CircularProgressIndicator(),
                ),
              ),
              ...game2Poi.map((point) {
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
                    onTap: () => _showPoiPopupMenu(point, poiKey),
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
