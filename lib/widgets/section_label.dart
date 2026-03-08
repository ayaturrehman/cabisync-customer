import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Consistent uppercase section header used across all screens.
/// Replaces duplicated `_buildSectionLabel` / `_sectionLabel` methods.
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
