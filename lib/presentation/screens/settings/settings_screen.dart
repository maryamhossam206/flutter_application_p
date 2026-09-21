import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/cubit_theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDark) {
        final backgroundColor = isDark ? Colors.black : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final dividerColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
        final titleColor = isDark ? const Color(0xFF8C82FF) : const Color(0xFF5A4FCF);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/products');
                }
              },
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: dividerColor,
                height: 1.0,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // 🟢 Profile Settings Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Profile Settings',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ⚪ Edit Profile (Static UI)
                _buildSimpleItem(
                  title: 'Edit Profile',
                  textColor: textColor,
                  dividerColor: dividerColor,
                ),

                // ⚪ Change Password (Static UI)
                _buildSimpleItem(
                  title: 'Change Password',
                  textColor: textColor,
                  dividerColor: dividerColor,
                ),

                // ⚪ Send Push Notifications (Static UI)
                _buildSwitchItem(
                  title: 'Send Push Notifications',
                  value: true,
                  textColor: textColor,
                  dividerColor: dividerColor,
                  onChanged: (val) {},
                ),

                // ⚪ Refresh automatically (Static UI)
                _buildSwitchItem(
                  title: 'Refresh automatically',
                  value: false,
                  textColor: textColor,
                  dividerColor: dividerColor,
                  onChanged: (val) {},
                ),

                // 🌙 / ☀️ Dark & Light Mode Switch (شغّال مع الأيقونات والقمر/الشمس)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                                  color: isDark ? const Color(0xFF8C82FF) : Colors.orangeAccent,
                                  size: 24,
                                ),
                                onPressed: () {
                                  context.read<ThemeCubit>().toggleTheme();
                                },
                              ),
                              Text(
                                isDark ? 'Night Mode' : 'Light Mode',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isDark,
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF8C82FF),
                            inactiveThumbColor: Colors.grey[300],
                            inactiveTrackColor: Colors.grey[600],
                            onChanged: (val) {
                              context.read<ThemeCubit>().toggleTheme();
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: dividerColor),
                  ],
                ),

                const SizedBox(height: 40),

                // 🔴 Log Out Button (بينقل للـ Login من غير ما نعدل في الـ Login screen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.15),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        context.go('/login');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleItem({
    required String title,
    required Color textColor,
    required Color dividerColor,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          onTap: () {},
        ),
        Divider(height: 1, thickness: 1, color: dividerColor),
      ],
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required Color textColor,
    required Color dividerColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Switch(
                value: value,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF8C82FF),
                inactiveThumbColor: Colors.grey[300],
                inactiveTrackColor: Colors.grey[600],
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: dividerColor),
      ],
    );
  }
}
