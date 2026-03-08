import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../services/api_service.dart';
import 'add_card_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, dynamic>> _cards = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService().get('/list-saved-cards');
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _cards = List<Map<String, dynamic>>.from(data['cards'] ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load cards';
        _loading = false;
      });
    }
  }

  Future<void> _setDefault(String id) async {
    try {
      await ApiService().post('/set-default-card/$id');
      _loadCards();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _deleteCard(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove card?'),
        content:
            const Text('This card will be removed from your account.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove',
                  style: TextStyle(color: AppColors.errorText))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiService().delete('/remove-card/$id');
      _loadCards();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _openAddCard() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddCardScreen()),
    );
    if (added == true) _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(title: 'Payment Methods'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _cards.isEmpty
                  ? _buildEmptyState()
                  : _buildCardList(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          child: CustomButton(
            text: 'Add New Card',
            icon: Icons.add,
            onPressed: _openAddCard,
            fullWidth: true,
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44, color: AppColors.accent),
          const SizedBox(height: AppSpacing.md),
          Text(_error!, style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.md),
          CustomButton(
            text: 'Retry',
            icon: Icons.refresh,
            variant: ButtonVariant.text,
            onPressed: _loadCards,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              ),
              child: const Icon(Icons.credit_card,
                  color: AppColors.white, size: 44),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No saved cards', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Add a payment method to pay for your rides quickly and securely.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      children: _cards.map((card) {
        final id = card['id'] as String;
        final brand = (card['brand'] as String? ?? 'Card').capitalize();
        final last4 = card['last4'] as String? ?? '••••';
        final expMonth = card['exp_month']?.toString().padLeft(2, '0') ?? '••';
        final expYear =
            (card['exp_year']?.toString() ?? '••').substring(2);
        final isDefault = card['is_default'] == true;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _CardTile(
            brand: brand,
            last4: last4,
            expiry: '$expMonth/$expYear',
            isDefault: isDefault,
            onSetDefault: () => _setDefault(id),
            onDelete: () => _deleteCard(id),
          ),
        );
      }).toList(),
    );
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

// ── Card tile ─────────────────────────────────────────────────────────────────

class _CardTile extends StatelessWidget {
  final String brand;
  final String last4;
  final String expiry;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _CardTile({
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.isDefault,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDefault ? AppColors.black : AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: isDefault ? AppColors.black : AppColors.border,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDefault
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              border: Border.all(
                color: isDefault
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.border,
              ),
            ),
            child: Icon(
              Icons.credit_card,
              color: isDefault ? AppColors.white : AppColors.black,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$brand •••• $last4',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDefault ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Expires $expiry',
                  style: AppTextStyles.caption.copyWith(
                    color: isDefault
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(AppBorderRadius.sm),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Text('Default',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                )
              else
                GestureDetector(
                  onTap: onSetDefault,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text('Set Default',
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline,
                    size: 18,
                    color: isDefault
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
