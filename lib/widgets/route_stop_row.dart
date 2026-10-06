import 'package:flutter/material.dart';

class RouteStopRow extends StatelessWidget {
  final String address;
  final int number;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onRemove;
  const RouteStopRow({
    super.key,
    required this.address,
    required this.number,
    this.onMoveUp,
    this.onMoveDown,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
    child: Row(
      children: [
        Text('$number', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stop $number',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Move stop $number up',
          onPressed: onMoveUp,
          icon: const Icon(Icons.arrow_upward, size: 18),
        ),
        IconButton(
          tooltip: 'Move stop $number down',
          onPressed: onMoveDown,
          icon: const Icon(Icons.arrow_downward, size: 18),
        ),
        IconButton(
          tooltip: 'Remove stop $number',
          onPressed: onRemove,
          icon: const Icon(Icons.close, size: 18),
        ),
      ],
    ),
  );
}
