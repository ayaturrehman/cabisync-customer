import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../auth/login_screen.dart';
import 'personal_information_screen.dart';
import 'payment_methods_screen.dart';
import 'saved_addresses_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    void open(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    Widget row(IconData icon, String title, Widget page) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, size: 23),
      title: Text(title, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () => open(page),
    );
    Widget section(String title, List<Widget> rows) => Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: AppTextStyles.caption),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Account',
        showBackButton: Navigator.of(context).canPop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Your account',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          section('Your details', [
            row(
              Icons.person_outline,
              'Personal information',
              const PersonalInformationScreen(),
            ),
            row(
              Icons.credit_card_outlined,
              'Payment methods',
              const PaymentMethodsScreen(),
            ),
            row(
              Icons.bookmark_border,
              'Saved places',
              const SavedAddressesScreen(),
            ),
          ]),
          section('Preferences & support', [
            row(
              Icons.notifications_none,
              'Notifications',
              const NotificationsScreen(),
            ),
            row(
              Icons.help_outline,
              'Help & support',
              const HelpSupportScreen(),
            ),
          ]),
          const SizedBox(height: 24),
          TextButton.icon(
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              minimumSize: const Size(0, 48),
            ),
            icon: const Icon(Icons.logout, size: 22),
            label: const Text('Sign out'),
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
