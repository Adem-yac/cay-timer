import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_state.dart';
import '../../core/persistence_keys.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_navigation.dart';
import '../widgets/caytimer_brand_header.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/status_badge_widget.dart';
import './widgets/active_blocks_widget.dart';
import './widgets/app_block_list_widget.dart';
import './widgets/block_duration_sheet_widget.dart';

class AppBlockModel {
  final String id;
  final String name;
  final String category;
  final IconData icon;
  final Color iconColor;
  final Uint8List? iconBytes;
  final String? packageName;
  BlockStatus blockStatus;
  bool isEnabled;
  int blockDurationMinutes;
  String? unblockTime;
  int? remainingMinutes;

  AppBlockModel({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.iconColor,
    this.iconBytes,
    this.packageName,
    required this.blockStatus,
    required this.isEnabled,
    required this.blockDurationMinutes,
    this.unblockTime,
    this.remainingMinutes,
  });

  factory AppBlockModel.fromInstalled(AppInfo info, Map<String, dynamic>? saved) {
    final persisted = saved ?? {};
    final enabled = persisted['isEnabled'] as bool? ?? false;
    final duration = persisted['blockDurationMinutes'] as int? ?? 30;
    final statusStr = persisted['blockStatus'] as String?;
    final status = statusStr != null
        ? _statusFromString(statusStr)
        : (enabled ? BlockStatus.active : BlockStatus.inactive);

    return AppBlockModel(
      id: info.packageName,
      packageName: info.packageName,
      name: info.name,
      category: info.category.name,
      icon: Icons.apps_rounded,
      iconColor: const Color(0xFFE91E8C),
      iconBytes: info.icon,
      blockStatus: status,
      isEnabled: enabled,
      blockDurationMinutes: duration,
      unblockTime: persisted['unblockTime'] as String?,
      remainingMinutes: persisted['remainingMinutes'] as int?,
    );
  }

  factory AppBlockModel.fromMap(Map<String, dynamic> m) {
    return AppBlockModel(
      id: m['id'] as String,
      name: m['name'] as String,
      category: m['category'] as String,
      icon: _iconFromString(m['icon'] as String? ?? 'app'),
      iconColor: Color(m['iconColor'] as int),
      iconBytes: null,
      packageName: m['packageName'] as String? ?? m['id'] as String?,
      blockStatus: _statusFromString(m['blockStatus'] as String),
      isEnabled: m['isEnabled'] as bool,
      blockDurationMinutes: m['blockDurationMinutes'] as int,
      unblockTime: m['unblockTime'] as String?,
      remainingMinutes: m['remainingMinutes'] as int?,
    );
  }

  static BlockStatus _statusFromString(String v) {
    switch (v) {
      case 'active':
        return BlockStatus.active;
      case 'scheduled':
        return BlockStatus.scheduled;
      default:
        return BlockStatus.inactive;
    }
  }

  static IconData _iconFromString(String v) {
    switch (v) {
      case 'facebook':
        return Icons.facebook_rounded;
      case 'instagram':
        return Icons.camera_alt_rounded;
      case 'youtube':
        return Icons.play_circle_fill_rounded;
      case 'tiktok':
        return Icons.music_video_rounded;
      case 'twitter':
        return Icons.alternate_email_rounded;
      case 'reddit':
        return Icons.forum_rounded;
      case 'netflix':
        return Icons.movie_rounded;
      case 'games':
        return Icons.sports_esports_rounded;
      case 'news':
        return Icons.newspaper_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'spotify':
        return Icons.headphones_rounded;
      case 'discord':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  Map<String, dynamic> toPersistMap() => {
    'id': id,
    'packageName': packageName ?? id,
    'name': name,
    'category': category,
    'icon': icon.codePoint.toString(),
    'blockStatus': blockStatus.name,
    'isEnabled': isEnabled,
    """
iconColor""": iconColor.value,
    'blockDurationMinutes': blockDurationMinutes,
    'unblockTime': unblockTime,
    'remainingMinutes': remainingMinutes,
  };
}

class BlockingScreen extends StatefulWidget {
  const BlockingScreen({super.key});

  @override
  State<BlockingScreen> createState() => _BlockingScreenState();
}

class _BlockingScreenState extends State<BlockingScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  final _appState = AppState();
  List<AppBlockModel> _apps = [];
  bool _loadingApps = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const _ownPackage = 'com.example.caytimer';

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadApps());
  }

  Future<void> _loadApps() async {
    setState(() => _loadingApps = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PersistenceKeys.userBlockingApps);
    final Map<String, Map<String, dynamic>> byPackage = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          final m = Map<String, dynamic>.from(e as Map);
          final pkg = m['packageName'] as String? ?? m['id'] as String?;
          if (pkg != null) byPackage[pkg] = m;
        }
      } catch (_) {}
    }

    if (!_isAndroid) {
      setState(() {
        _apps = [];
        _loadingApps = false;
      });
      await _persistAll();
      return;
    }

    try {
      final installed = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        excludeNonLaunchableApps: true,
        withIcon: true,
      );
      final filtered = installed
          .where((a) => a.packageName != _ownPackage)
          .toList();
      setState(() {
        _apps = filtered
            .map(
              (info) => AppBlockModel.fromInstalled(
                info,
                byPackage[info.packageName],
              ),
            )
            .toList();
        _loadingApps = false;
      });
    } catch (_) {
      setState(() {
        _apps = [];
        _loadingApps = false;
      });
    }
    await _persistAll();
  }

  Future<void> _persistAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_apps.map((a) => a.toPersistMap()).toList());
    await prefs.setString(PersistenceKeys.userBlockingApps, jsonStr);
    final blockedPkgs = _apps
        .where((a) => a.isEnabled && (a.packageName ?? a.id).isNotEmpty)
        .map((a) => a.packageName ?? a.id)
        .toList();
    await prefs.setString(
      PersistenceKeys.blockedPackageNames,
      jsonEncode(blockedPkgs),
    );
    _syncPreview();
  }

  void _syncPreview() {
    final active = _apps
        .where((a) => a.isEnabled && a.blockStatus == BlockStatus.active)
        .map(
          (a) => BlockedAppTileData(
            name: a.name,
            iconBytes: a.iconBytes,
            blockedForLabel: a.remainingMinutes != null && a.remainingMinutes! > 0
                ? '${a.remainingMinutes}m'
                : '${a.blockDurationMinutes}m',
            unlockHint: a.unblockTime,
          ),
        )
        .toList();
    _appState.setBlockedAppsPreview(active);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChanged() => setState(() {});
  String _t(String key) => _appState.t(key);

  List<AppBlockModel> get _filteredApps {
    return _apps.where((app) {
      final matchesSearch = app.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesSearch;
    }).toList();
  }

  List<AppBlockModel> get _activeBlocks =>
      _apps.where((a) => a.blockStatus == BlockStatus.active).toList();

  void _toggleApp(String id) {
    setState(() {
      final idx = _apps.indexWhere((a) => a.id == id);
      if (idx != -1) {
        final app = _apps[idx];
        app.isEnabled = !app.isEnabled;
        app.blockStatus = app.isEnabled
            ? BlockStatus.active
            : BlockStatus.inactive;
        if (!app.isEnabled) {
          app.unblockTime = null;
          app.remainingMinutes = null;
        } else {
          app.remainingMinutes = app.blockDurationMinutes;
        }
      }
    });
    _persistAll();
  }

  void _showDurationSheet(AppBlockModel app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlockDurationSheetWidget(
        app: app,
        onSave: (duration) {
          setState(() {
            final idx = _apps.indexWhere((a) => a.id == app.id);
            if (idx != -1) {
              _apps[idx].blockDurationMinutes = duration;
              _apps[idx].remainingMinutes = duration;
            }
          });
          _persistAll();
        },
      ),
    );
  }

  void _blockAll() {
    setState(() {
      for (final app in _apps) {
        app.isEnabled = true;
        app.blockStatus = BlockStatus.active;
        app.remainingMinutes = app.blockDurationMinutes;
      }
    });
    _persistAll();
  }

  void _unblockAll() {
    setState(() {
      for (final app in _apps) {
        app.isEnabled = false;
        app.blockStatus = BlockStatus.inactive;
        app.unblockTime = null;
        app.remainingMinutes = null;
      }
    });
    _persistAll();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.6, -0.4),
                  radius: 0.7,
                  colors: [Color(0x221E40AF), AppTheme.darkBackground],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
          ),
        ],
      ),
      bottomNavigationBar: AppNavigation(currentIndex: 2),
    );
  }

  Widget _buildPhoneLayout() {
    return Column(
      children: [
        _buildAppBar(),
        _buildSearchBar(),
        _buildQuickActions(),
        Expanded(
          child: _loadingApps
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryPink),
                )
              : RefreshIndicator(
                  color: AppTheme.primaryPink,
                  backgroundColor: AppTheme.darkSurface,
                  onRefresh: _loadApps,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (_isAndroid && _activeBlocks.isNotEmpty)
                        SliverToBoxAdapter(
                          child: ActiveBlocksWidget(
                            activeApps: _activeBlocks,
                            onUnblockAll: _unblockAll,
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                          child: Row(
                            children: [
                              Text(
                                _t('all_apps'),
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_filteredApps.length} ${_t('apps')}',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!_isAndroid)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyStateWidget(
                            icon: Icons.phone_android_rounded,
                            title: _t('blocking_android_only_title'),
                            subtitle: _t('blocking_android_only_sub'),
                          ),
                        )
                      else if (_apps.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyStateWidget(
                            icon: Icons.apps_outage_rounded,
                            title: _t('no_apps_found'),
                            subtitle: _t('blocking_pull_refresh'),
                          ),
                        )
                      else if (_filteredApps.isEmpty)
                        SliverFillRemaining(
                          child: EmptyStateWidget(
                            icon: Icons.search_off_rounded,
                            title: _t('no_apps_found'),
                            subtitle: _t('try_different_search'),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          sliver: AppBlockListWidget(
                            apps: _filteredApps,
                            onToggle: _toggleApp,
                            onDurationTap: _showDurationSheet,
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        SizedBox(
          width: 360,
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildQuickActions(),
              Expanded(
                child: _loadingApps
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryPink,
                        ),
                      )
                    : !_isAndroid
                    ? EmptyStateWidget(
                        icon: Icons.phone_android_rounded,
                        title: _t('blocking_android_only_title'),
                        subtitle: _t('blocking_android_only_sub'),
                      )
                    : _apps.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.apps_outage_rounded,
                        title: _t('no_apps_found'),
                        subtitle: _t('blocking_pull_refresh'),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                              child: Text(
                                _t('all_apps'),
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            sliver: AppBlockListWidget(
                              apps: _filteredApps,
                              onToggle: _toggleApp,
                              onDurationTap: _showDurationSheet,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.white.withAlpha(20), width: 1),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 80),
                if (_isAndroid && _activeBlocks.isNotEmpty)
                  ActiveBlocksWidget(
                    activeApps: _activeBlocks,
                    onUnblockAll: _unblockAll,
                  ),
                if (_isAndroid && _activeBlocks.isEmpty)
                  Expanded(
                    child: EmptyStateWidget(
                      icon: Icons.shield_outlined,
                      title: _t('no_active_blocks'),
                      subtitle: _t('enable_blocking_focus'),
                    ),
                  ),
                if (!_isAndroid)
                  Expanded(
                    child: EmptyStateWidget(
                      icon: Icons.shield_outlined,
                      title: _t('blocking_android_only_title'),
                      subtitle: _t('blocking_android_only_sub'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CaytimerBrandHeader(title: _t('app_name')),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.accountSettings);
            },
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white70,
              size: 22,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(31),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.error.withAlpha(77)),
            ),
            child: Row(
              children: [
                Icon(Icons.block_rounded, color: AppTheme.error, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${_activeBlocks.length} Active',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.manrope(color: Colors.white, fontSize: 14),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: GoogleFonts.manrope(
                  color: Colors.white38,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: Colors.white38,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _blockAll,
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPink, AppTheme.secondaryViolet],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withAlpha(77),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.block_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _t('block_all'),
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _unblockAll,
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(31)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_open_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _t('unblock_all'),
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}