import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Pickup → dropoff route display used in ride booking and ride history.
/// Replaces duplicated dot + line + dot Container patterns.
class RouteVisualization extends StatelessWidget {
  final String pickup;
  final String dropoff;

  const RouteVisualization({
    super.key,
    required this.pickup,
    required this.dropoff,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot-line-dot column
        Column(
          children: [
            const _Dot(filled: true),
            Container(width: 2, height: 20, color: AppColors.border),
            const _Dot(filled: false),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        // Address labels
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickup,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.lg),
              Text(dropoff,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool filled;
  const _Dot({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: filled ? AppColors.black : AppColors.white,
        shape: BoxShape.circle,
        border: filled ? null : Border.all(color: AppColors.black, width: 2),
      ),
    );
  }
}
