import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:century_cqg/Helper/nerve_colors.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Screens/Dashboard/service/dasboard_service.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardService>(
      builder: (context, service, _) {
        final isDarkMode = NerveBase().isDarkMode;
        final bgColor = NerveColors.projectBackgroundColor(isDarkMode);
        final cardColor = NerveColors.appBarBackground(isDarkMode);
        final borderColor =
            isDarkMode
                ? const Color(0xFF282D2A)
                : NerveColors.containerBorderColor;
        final subtitleColor =
            isDarkMode ? const Color(0xFFB5B5B5) : const Color(0xFF8F8F8F);
        final rowTextColor =
            isDarkMode ? Colors.white : const Color(0xFF505050);
        final appearanceRowBg =
            isDarkMode ? NerveColors.darkProjectBackground : cardColor;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: cardColor,
            iconTheme: IconThemeData(color: rowTextColor),
            titleSpacing: 0,
            title: Text(
              'APP SETTINGS',
              style: TextStyle(
                color: rowTextColor,
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: 0,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: borderColor),
            ),
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 18, 10, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsSection(
                    title: 'Profile',
                    titleColor: subtitleColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    rowTextColor: rowTextColor,
                    items: const [
                      'Personal Information',
                      'Two-Factor Authentication',
                      'Change Password',
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SettingsSection(
                    title: 'Trading',
                    titleColor: subtitleColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    rowTextColor: rowTextColor,
                    items: const [
                      'Default Leverage',
                      'Risk Management',
                      'Order Confirmation',
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SettingsSection(
                    title: 'Notifications',
                    titleColor: subtitleColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    rowTextColor: rowTextColor,
                    items: const [
                      'Price Alerts',
                      'Order Updates',
                      'Account Activity',
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SettingsSection(
                    title: 'Appearance',
                    titleColor: subtitleColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    rowTextColor: rowTextColor,
                    rows: [
                      _SectionRow(
                        title: 'Dark Mode',
                        rowTextColor: rowTextColor,
                        backgroundColor: appearanceRowBg,
                        showChevron: false,
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: service.setDarkMode,
                          activeColor: NerveColors.selectedNavColor,
                          activeTrackColor: NerveColors.selectedNavColor
                              .withOpacity(0.45),
                          inactiveThumbColor: const Color(0xFF8A8A8A),
                          inactiveTrackColor: const Color(0xFFD0D0D0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color cardColor;
  final Color borderColor;
  final Color rowTextColor;
  final List<String> items;
  final List<_SectionRow>? rows;

  const _SettingsSection({
    required this.title,
    required this.titleColor,
    required this.cardColor,
    required this.borderColor,
    required this.rowTextColor,
    this.items = const [],
    this.rows,
  }) : assert(rows != null || items.length > 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate((rows ?? _rowsFromItems()).length, (index) {
              final currentRows = rows ?? _rowsFromItems();
              return Column(
                children: [
                  currentRows[index],
                  if (index != currentRows.length - 1)
                    Divider(height: 1, thickness: 1, color: borderColor),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  List<_SectionRow> _rowsFromItems() {
    return items
        .map((title) => _SectionRow(title: title, rowTextColor: rowTextColor))
        .toList();
  }
}

class _SectionRow extends StatelessWidget {
  final String title;
  final Color rowTextColor;
  final Widget? trailing;
  final bool showChevron;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const _SectionRow({
    required this.title,
    required this.rowTextColor,
    this.trailing,
    this.showChevron = true,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: rowTextColor,
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showChevron)
                Icon(
                  Icons.chevron_right,
                  color: rowTextColor.withOpacity(0.5),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
