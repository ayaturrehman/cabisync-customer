import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/shimmer_loading.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final bool _isLoading = false;

  final List<RideHistoryItem> _rides = [
    RideHistoryItem(
      id: '1',
      from: '123 Main Street',
      to: '456 Office Building',
      date: '2 hours ago',
      price: '\$15.50',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: '2',
      from: '789 Home Avenue',
      to: 'Central Shopping Mall',
      date: 'Yesterday',
      price: '\$22.00',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: '3',
      from: '321 Park Lane',
      to: 'Airport Terminal',
      date: '3 days ago',
      price: '\$45.00',
      status: 'Completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'Ride History',
        showBackButton: false,
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 5,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemBuilder: (context, index) => const ShimmerCard(),
            )
          : _rides.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _rides.length,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemBuilder: (context, index) {
                    return _buildRideCard(_rides[index], index);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
            child: const Icon(
              Icons.history,
              size: 48,
              color: AppColors.accent,
            ),
          )
              .animate()
              .fadeIn(duration: AppAnimations.medium)
              .scale(duration: AppAnimations.medium),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No rides yet',
            style: AppTextStyles.heading3,
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your ride history will appear here',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideHistoryItem ride, int index) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: const Icon(
                  Icons.local_taxi,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.date,
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      ride.price,
                      style: AppTextStyles.heading3,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  ride.status,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    color: AppColors.border,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.black, width: 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.from,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      ride.to,
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: AppAnimations.fast)
        .slideY(begin: 0.1, end: 0);
  }
}

class RideHistoryItem {
  final String id;
  final String from;
  final String to;
  final String date;
  final String price;
  final String status;

  RideHistoryItem({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
    required this.price,
    required this.status,
  });
}
