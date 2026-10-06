import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Consistent, labelled journey summary; addresses wrap on small screens.
class RouteVisualization extends StatelessWidget {
  const RouteVisualization({
    super.key,
    required this.pickup,
    required this.dropoff,
  });
  final String pickup;
  final String dropoff;

  @override
  Widget build(BuildContext context) {
    Widget stop(String label, String address, IconData icon) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(icon, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(address, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        stop('Pickup', pickup, Icons.trip_origin),
        const SizedBox(height: 18),
        stop('Destination', dropoff, Icons.location_on_outlined),
      ],
    );
  }
}
