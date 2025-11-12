import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';

class DriverInfoCard extends StatelessWidget {
  final String name;
  final String vehicleInfo;
  final String plateNumber;
  final double rating;
  final String? photoUrl;
  final VoidCallback? onCallTap;
  final VoidCallback? onMessageTap;

  const DriverInfoCard({
    super.key,
    required this.name,
    required this.vehicleInfo,
    required this.plateNumber,
    required this.rating,
    this.photoUrl,
    this.onCallTap,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.black, width: 2),
              color: AppColors.surface,
            ),
            child: ClipOval(
              child: photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.accent,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 32,
                      color: AppColors.accent,
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.heading3,
                      ),
                    ),
                    const Icon(Icons.star, size: 16, color: AppColors.black),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  vehicleInfo,
                  style: AppTextStyles.caption,
                ),
                Text(
                  plateNumber,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            children: [
              if (onCallTap != null)
                IconButton(
                  onPressed: onCallTap,
                  icon: const Icon(Icons.phone),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                  ),
                ),
              if (onMessageTap != null) ...[
                const SizedBox(height: AppSpacing.xs),
                IconButton(
                  onPressed: onMessageTap,
                  icon: const Icon(Icons.message),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.black,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
