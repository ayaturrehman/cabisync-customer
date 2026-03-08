import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../services/booking_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/route_visualization.dart';
import '../../widgets/shimmer_loading.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final BookingService _bookingService = BookingService(ApiService());
  bool _isLoading = true;
  List<Booking> _rides = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rides = await _bookingService.getBookingHistory();
      if (mounted) {
        setState(() {
          _rides = rides;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

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
          : _errorMessage != null
              ? _buildErrorState()
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomButton(
              text: 'Retry',
              icon: Icons.refresh,
              variant: ButtonVariant.text,
              onPressed: _loadHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(Booking ride, int index) {
    final now = DateTime.now();
    final date = ride.createdAt;
    String dateLabel = '';
    if (date != null) {
      final diff = now.difference(date);
      if (diff.inHours < 24) {
        dateLabel = '${diff.inHours}h ago';
      } else if (diff.inDays == 1) {
        dateLabel = 'Yesterday';
      } else if (diff.inDays < 7) {
        dateLabel = '${diff.inDays} days ago';
      } else {
        dateLabel = '${date.day}/${date.month}/${date.year}';
      }
    }

    final priceLabel = ride.fare != null ? '£${ride.fare!.toStringAsFixed(2)}' : '';
    final statusLabel = ride.status[0].toUpperCase() + ride.status.substring(1).replaceAll('_', ' ');

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
                    Text(dateLabel, style: AppTextStyles.caption),
                    Text(priceLabel, style: AppTextStyles.heading3),
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
                  statusLabel,
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          RouteVisualization(
            pickup: ride.pickupAddress,
            dropoff: ride.dropoffAddress,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: AppAnimations.fast)
        .slideY(begin: 0.1, end: 0);
  }
}
