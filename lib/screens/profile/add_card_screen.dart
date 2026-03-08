import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../config/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/section_label.dart';
import '../../services/api_service.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  bool _isLoading = false;

  // Stripe publishable key — safe to expose in client
  static const _stripePk =
      'pk_test_51L5JsHBdSzFT1vJtLcF9QgSxBU8Cb2V6etW7ERorifdSmsNHSetKehDYSpmxRebQO85G1pgbFcjRFo2wywiTazA000Udo0C9ZA';

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final expParts = _expiryController.text.split('/');
      final expMonth = expParts[0].trim();
      final expYear = '20${expParts[1].trim()}';
      final cardNumber = _numberController.text.replaceAll(' ', '');

      // Step 1 — create PaymentMethod via Stripe REST API
      final stripe = Dio(BaseOptions(
        baseUrl: 'https://api.stripe.com/v1',
        contentType: 'application/x-www-form-urlencoded',
        headers: {'Authorization': 'Bearer $_stripePk'},
      ));

      final stripeRes = await stripe.post('/payment_methods', data: {
        'type': 'card',
        'card[number]': cardNumber,
        'card[exp_month]': expMonth,
        'card[exp_year]': expYear,
        'card[cvc]': _cvcController.text.trim(),
        'billing_details[name]': _nameController.text.trim(),
      });

      final pmId = stripeRes.data['id'] as String;

      // Step 2 — attach to backend
      await ApiService().post('/create-payment-method', data: {
        'payment_method_id': pmId,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      debugPrint('💳 DioException on add card:');
      debugPrint('   status: ${e.response?.statusCode}');
      debugPrint('   data:    ${e.response?.data}');
      debugPrint('   message: ${e.message}');
      final msg = e.response?.data?['error']?['message'] ?? e.message ?? 'Failed to add card';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e, st) {
      debugPrint('💳 Unexpected error on add card: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(title: 'Add Card'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _CardPreview(
              numberCtrl: _numberController,
              nameCtrl: _nameController,
              expiryCtrl: _expiryController,
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionLabel('CARD DETAILS'),
            const SizedBox(height: AppSpacing.sm),
            CustomTextField(
              label: 'Card Number',
              hint: '1234 5678 9012 3456',
              controller: _numberController,
              prefixIcon: Icons.credit_card,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CardNumberFormatter(),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.replaceAll(' ', '').length < 16) return 'Enter 16 digits';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              label: 'Cardholder Name',
              hint: 'John Smith',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.name,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Expanded(
                child: CustomTextField(
                  label: 'Expiry',
                  hint: 'MM/YY',
                  controller: _expiryController,
                  prefixIcon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryFormatter(),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) return 'MM/YY';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  label: 'CVC',
                  hint: '•••',
                  controller: _cvcController,
                  prefixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 3) return 'Min 3 digits';
                    return null;
                  },
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock, size: 13, color: AppColors.accent),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Secured by Stripe  —  card details never stored on our servers',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.accent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ]),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          child: CustomButton(
            text: 'Add Card',
            onPressed: _isLoading ? null : _submit,
            isLoading: _isLoading,
            fullWidth: true,
          ),
        ),
      ),
    );
  }

}

// ── Card preview ──────────────────────────────────────────────────────────────

class _CardPreview extends StatelessWidget {
  final TextEditingController numberCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController expiryCtrl;

  const _CardPreview({
    required this.numberCtrl,
    required this.nameCtrl,
    required this.expiryCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([numberCtrl, nameCtrl, expiryCtrl]),
      builder: (context, child) {
        final raw = numberCtrl.text.replaceAll(' ', '');
        final grouped = [
          raw.padRight(16, '•').substring(0, 4),
          raw.padRight(16, '•').substring(4, 8),
          raw.padRight(16, '•').substring(8, 12),
          raw.padRight(16, '•').substring(12, 16),
        ].join('  ');

        final name = nameCtrl.text.isEmpty
            ? 'CARDHOLDER NAME'
            : nameCtrl.text.toUpperCase();
        final expiry =
            expiryCtrl.text.isEmpty ? 'MM/YY' : expiryCtrl.text;

        return Container(
          height: 190,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chip
                  Container(
                    width: 36,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // NFC icon
                  Icon(Icons.wifi,
                      color: Colors.white.withValues(alpha: 0.4), size: 22),
                ],
              ),
              const Spacer(),
              Text(
                grouped,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.white,
                  letterSpacing: 2.5,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cardLabel('CARDHOLDER', name),
                  _cardLabel('EXPIRES', expiry),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cardLabel(String title, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.overline.copyWith(
                  color: AppColors.accent, fontSize: 9, letterSpacing: 1.2)),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.white, fontWeight: FontWeight.w600)),
        ],
      );
}

// ── Input formatters ──────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    if (digits.length > 16) return old;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('/', '');
    if (digits.length > 4) return old;
    final s = digits.length >= 3
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}
