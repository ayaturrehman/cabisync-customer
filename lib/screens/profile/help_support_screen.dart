import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/section_label.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How do I book a ride?',
      'a':
          'Open the app, enter your pickup and destination, choose a vehicle type, then tap "Book Ride". You will be matched with a nearby driver within seconds.',
    },
    {
      'q': 'How do I cancel a booking?',
      'a':
          'Go to your active booking on the home screen and tap "Cancel Ride". Cancellations made within 2 minutes of booking are free. A small fee may apply after that.',
    },
    {
      'q': 'How are fares calculated?',
      'a':
          'Fares are based on distance, estimated journey time, vehicle category, and any applicable surcharges (e.g. peak hours). You will always see a fare estimate before confirming.',
    },
    {
      'q': 'How do I get a refund?',
      'a':
          'If you were charged incorrectly, contact our support team via chat or email within 7 days of the trip. Refunds are typically processed within 3–5 business days.',
    },
  ];

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(title: 'Help & Support'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SizedBox(height: AppSpacing.sm),
          SectionLabel('FAQ'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              child: Column(
                children: _faqs.asMap().entries.map((entry) {
                  final isLast = entry.key == _faqs.length - 1;
                  final faq = entry.value;
                  return _FaqTile(
                    question: faq['q']!,
                    answer: faq['a']!,
                    isLast: isLast,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionLabel('Contact Us'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _ContactTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat Support',
                  subtitle: 'Available 24/7',
                  isLast: false,
                  onTap: () => _showSnackBar(context, 'Chat support coming soon'),
                ),
                _ContactTile(
                  icon: Icons.email_outlined,
                  title: 'Email Us',
                  subtitle: 'support@cabisync.com',
                  isLast: false,
                  onTap: () =>
                      _showSnackBar(context, 'support@cabisync.com'),
                ),
                _ContactTile(
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  subtitle: '+44 000 000 0000',
                  isLast: true,
                  onTap: () =>
                      _showSnackBar(context, '+44 000 000 0000'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

}

// ──────────────────────────────────────────────────────────────────────────────
// FAQ expansion tile
// ──────────────────────────────────────────────────────────────────────────────

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isLast;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.8),
              ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          iconColor: AppColors.black,
          collapsedIconColor: AppColors.accent,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer,
              style: AppTextStyles.bodySecondary.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Contact tile
// ──────────────────────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        bottom: isLast
            ? const Radius.circular(AppBorderRadius.lg)
            : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.8),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
