import 'package:flutter/material.dart';
import '../config/theme.dart';

class BottomSheetModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showDragHandle;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const BottomSheetModal({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.height,
    this.padding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showDragHandle = true,
    double? height,
    EdgeInsetsGeometry? padding,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetModal(
        title: title,
        showDragHandle: showDragHandle,
        height: height,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Text(
                title!,
                style: AppTextStyles.heading3,
              ),
            ),
            const Divider(height: 1),
          ],
          Flexible(
            child: Padding(
              padding: padding ??
                  const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
