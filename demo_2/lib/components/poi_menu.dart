import 'package:demo_2/models/models.dart';
import 'package:flutter/material.dart';

class PointOfInterestCardMenu extends StatelessWidget {
  final PointOfInterest point;
  final VoidCallback onDismiss;

  const PointOfInterestCardMenu({
    super.key,
    required this.point,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  point.label,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onDismiss, // Dismiss on close icon tap
                child: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            'Coordinates: (${point.x.toInt()}, ${point.y.toInt()})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8.0),
        Center(
          child: ElevatedButton(
            onPressed: () {
              debugPrint('Exploring ${point.label}!');
              onDismiss(); // Dismiss the menu after action
            },
            child: const Text('Explore'),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              onDismiss(); // Dismiss the menu before navigation
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Placeholder()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Battle'),
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
