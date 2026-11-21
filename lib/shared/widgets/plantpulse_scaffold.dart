import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../features/alerts/alerts_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/plants/plants_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../l10n/app_localizations.dart';

class PlantPulseScaffold extends StatelessWidget {
  final int currentIndex;
  final Widget child;
  final bool showBottomNavigation;

  const PlantPulseScaffold({
    super.key,
    required this.currentIndex,
    required this.child,
    this.showBottomNavigation = true,
  });

  static const pages = [
    HomeScreen(),
    PlantsScreen(),
    ScanScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  void _select(BuildContext context, int index) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => pages[index]));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar:
          showBottomNavigation
              ? NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) => _select(context, index),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: strings.navHome,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.local_florist_outlined),
                    selectedIcon: const Icon(Icons.local_florist_rounded),
                    label: strings.navPlants,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.center_focus_weak_rounded),
                    selectedIcon: const Icon(Icons.center_focus_strong_rounded),
                    label: strings.navScan,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.notifications_none_rounded),
                    selectedIcon: const Icon(Icons.notifications_rounded),
                    label: strings.navAlerts,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    selectedIcon: const Icon(Icons.person_rounded),
                    label: strings.navProfile,
                  ),
                ],
              )
              : null,
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool back;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.back = false,
  });

  Widget _titleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(color: PlantPulseColors.muted, fontSize: 13),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 400;

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (back)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  Expanded(child: _titleContent()),
                ],
              ),
              if (trailing != null) ...[
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: trailing!),
              ],
            ],
          );
        }

        return Row(
          children: [
            if (back)
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            Expanded(child: _titleContent()),
            if (trailing != null) trailing!,
          ],
        );
      },
    );
  }
}

class StatusPill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.text,
    required this.background,
    required this.foreground,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class PlantIcon extends StatelessWidget {
  final double size;

  const PlantIcon({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: PlantPulseColors.mint,
        borderRadius: BorderRadius.circular(size * .28),
      ),
      child: Icon(
        Icons.eco_rounded,
        color: PlantPulseColors.green,
        size: size * .55,
      ),
    );
  }
}
