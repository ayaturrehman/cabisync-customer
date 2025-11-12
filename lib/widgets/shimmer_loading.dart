import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape,
  });

  const ShimmerLoading.rectangular({
    super.key,
    required this.width,
    required this.height,
    double borderRadiusValue = AppBorderRadius.sm,
  })  : borderRadius = const BorderRadius.all(Radius.circular(AppBorderRadius.sm)),
        shape = null;

  const ShimmerLoading.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null,
        shape = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.white,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
              ),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerLoading.circular(size: 48),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading.rectangular(
                      width: 150,
                      height: 16,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerLoading.rectangular(
                      width: 100,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ShimmerLoading.rectangular(
            width: double.infinity,
            height: 12,
          ),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading.rectangular(
            width: 200,
            height: 12,
          ),
        ],
      ),
    );
  }
}
