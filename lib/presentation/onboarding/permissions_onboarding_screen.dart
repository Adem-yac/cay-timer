import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_state.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class PermissionsOnboardingScreen extends StatefulWidget {
  const PermissionsOnboardingScreen({super.key});

  @override
  State<PermissionsOnboardingScreen> createState() =>
      _PermissionsOnboardingScreenState();
}

class _PermissionsOnboardingScreenState
    extends State<PermissionsOnboardingScreen>
    with SingleTickerProviderStateMixin {
  bool _notifGranted = false;
  bool _blockingGranted = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _notifGranted = AppState().notificationsEnabled;
    _blockingGranted = AppState().blockingPermissionGranted;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  final _appState = AppState();

  String _t(String key) => _appState.t(key);

  void _grantNotif() async {
    // Simulate permission grant (real permission handled by OS)
    await AppState().setNotificationsEnabled(true);
    setState(() => _notifGranted = true);
  }

  void _grantBlocking() async {
    await AppState().setBlockingPermissionGranted(true);
    setState(() => _blockingGranted = true);
  }

  void _onGetStarted() async {
    await AppState().setOnboardingComplete(true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.focusTimerScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 0.9,
                  colors: [Color(0x337C3AED), AppTheme.darkBackground],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.secondaryViolet,
                            AppTheme.primaryPink,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryViolet.withAlpha(80),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _t('permissions'),
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Allow Caytimer to work at its best',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildPermissionCard(
                      icon: Icons.notifications_rounded,
                      iconColor: AppTheme.primaryPink,
                      title: _t('notif_permission'),
                      description: _t('notif_permission_desc'),
                      isGranted: _notifGranted,
                      onGrant: _grantNotif,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.block_rounded,
                      iconColor: AppTheme.secondaryViolet,
                      title: _t('blocking_permission'),
                      description: _t('blocking_permission_desc'),
                      isGranted: _blockingGranted,
                      onGrant: _grantBlocking,
                    ),
                    const Spacer(),
                    _buildInfoNote(),
                    const SizedBox(height: 20),
                    _buildGetStartedButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onGrant,
  }) {
    return Semantics(
      label: '$title permission card',
      hint:
          isGranted
              ? 'Permission already granted'
              : 'Double tap the grant button to request permission',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isGranted ? iconColor.withAlpha(100) : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isGranted ? null : onGrant,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isGranted ? iconColor.withAlpha(30) : iconColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isGranted ? _t('granted') : _t('grant'),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isGranted ? iconColor : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.white38,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can change permissions anytime in Settings',
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Semantics(
      label: 'Get started button',
      hint: 'Double tap to complete onboarding and start using the app',
      child: GestureDetector(
        onTap: _onGetStarted,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryPink, AppTheme.secondaryViolet],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _t('get_started'),
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}