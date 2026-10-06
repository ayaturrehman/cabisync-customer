import 'package:flutter/material.dart';
import '../config/theme.dart';

class RideTypeCard extends StatelessWidget {
  final String name;
  final String capacity;
  final String estimatedTime;
  final String price;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const RideTypeCard({
    super.key,
    required this.name,
    required this.capacity,
    required this.estimatedTime,
    required this.price,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.defaultCurve,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand : AppColors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : AppColors.black,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.heading3.copyWith(
                      color: isSelected ? Colors.white : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Journey · $estimatedTime',
                    style: AppTextStyles.caption.copyWith(
                      color:
                          isSelected ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: AppTextStyles.heading3.copyWith(
                color: isSelected ? Colors.white : AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
