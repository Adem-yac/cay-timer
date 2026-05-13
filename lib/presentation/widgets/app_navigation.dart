import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_state.dart';
import '../routes/app_routes.dart';

class AppNavigation extends StatelessWidget {
  final int currentIndex;

  const AppNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    if (isTablet) {
      return _TabletRail(currentIndex: currentIndex);
    }
    return _LiquidGlassBottomNav(currentIndex: currentIndex);
  }
}

class _LiquidGlassBottomNav extends StatelessWidget {
  final int currentIndex;

  const _LiquidGlassBottomNav({required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    final routes = [
      AppRoutes.focusTimerScreen,
      AppRoutes.goalsScreen,
      AppRoutes.blockingScreen,
    ];
    if (index != currentIndex) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppState().t;
    final items = [
      _NavItem(icon: Icons.timer_rounded, label: t('timer'), index: 0),
      _NavItem(icon: Icons.flag_rounded, label: t('goals'), index: 1),
      _NavItem(icon: Icons.block_rounded, label: t('blocking'), index: 2),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0x33FFFFFF), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.map((item) {
                final isActive = currentIndex == item.index;
                return GestureDetector(
                  onTap: () => _onTap(context, item.index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE91E8C).withAlpha(51)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            item.icon,
                            key: ValueKey(isActive),
                            size: 22,
                            color: isActive
                                ? const Color(0xFFE91E8C)
                                : Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? const Color(0xFFE91E8C)
                                : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabletRail extends StatelessWidget {
  final int currentIndex;

  const _TabletRail({required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    final routes = [
      AppRoutes.focusTimerScreen,
      AppRoutes.goalsScreen,
      AppRoutes.blockingScreen,
      AppRoutes.accountSettings,
    ];
    if (index != currentIndex) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppState().t;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            border: Border(
              right: BorderSide(color: const Color(0x33FFFFFF), width: 1),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildRailItem(context, Icons.timer_rounded, t('timer'), 0),
              const SizedBox(height: 8),
              _buildRailItem(context, Icons.flag_rounded, t('goals'), 1),
              const SizedBox(height: 8),
              _buildRailItem(context, Icons.block_rounded, t('blocking'), 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRailItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFE91E8C).withAlpha(51)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? const Color(0xFFE91E8C) : Colors.white54,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFFE91E8C) : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  _NavItem({required this.icon, required this.label, required this.index});
}
