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
          color: isSelected ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.white : AppColors.black,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.heading3.copyWith(
                      color: isSelected ? AppColors.white : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$capacity • $estimatedTime',
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? AppColors.white.withOpacity(0.8) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: AppTextStyles.heading3.copyWith(
                color: isSelected ? AppColors.white : AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
