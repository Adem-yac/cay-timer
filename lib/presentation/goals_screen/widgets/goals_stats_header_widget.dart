import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_state.dart';
import '../../../core/persistence_keys.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/caytimer_brand_header.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/status_badge_widget.dart';
import './add_goal_sheet_widget.dart';
import './goal_card_widget.dart';

class GoalsStatsHeaderWidget extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final double completionRate;
  final GoalPeriod period;

  const GoalsStatsHeaderWidget({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.completionRate,
    required this.period,
  });

  String get _periodLabel {
    switch (period) {
      case GoalPeriod.weekly:
        return 'This Week';
      case GoalPeriod.monthly:
        return 'This Month';
      case GoalPeriod.daily:
        return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _periodLabel,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$completedCount / $totalCount goals',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: completionRate,
                minHeight: 6,
                backgroundColor: Colors.white.withAlpha(24),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryPink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum GoalPeriod { daily, weekly, monthly }

class GoalModel {
  final String id;
  final String title;
  final String description;
  final GoalPeriod period;
  final GoalStatus status;
  final double progress;
  final int targetMinutes;
  final int completedMinutes;
  final bool notificationEnabled;
  final String category;
  final IconData icon;
  final Color color;

  const GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.period,
    required this.status,
    required this.progress,
    required this.targetMinutes,
    required this.completedMinutes,
    required this.notificationEnabled,
    required this.category,
    required this.icon,
    required this.color,
  });

  factory GoalModel.fromMap(Map<String, dynamic> m) {
    return GoalModel(
      id: m['id'] as String,
      title: m['title'] as String,
      description: m['description'] as String,
      period: _periodFromString(m['period'] as String),
      status: _statusFromString(m['status'] as String),
      progress: (m['progress'] as num).toDouble(),
      targetMinutes: m['targetMinutes'] as int,
      completedMinutes: m['completedMinutes'] as int,
      notificationEnabled: m['notificationEnabled'] as bool,
      category: m['category'] as String,
      icon: _iconFromDynamic(m['icon']),
      color: Color(m['color'] as int),
    );
  }

  static IconData _iconFromDynamic(dynamic v) {
    if (v is int) {
      return IconData(v, fontFamily: 'MaterialIcons');
    }
    if (v is String) {
      final code = int.tryParse(v);
      if (code != null) {
        return IconData(code, fontFamily: 'MaterialIcons');
      }
      return _iconFromString(v);
    }
    return Icons.flag_rounded;
  }

  static GoalPeriod _periodFromString(String v) {
    switch (v) {
      case 'weekly':
        return GoalPeriod.weekly;
      case 'monthly':
        return GoalPeriod.monthly;
      default:
        return GoalPeriod.daily;
    }
  }

  static GoalStatus _statusFromString(String v) {
    switch (v) {
      case 'completed':
        return GoalStatus.completed;
      case 'inProgress':
        return GoalStatus.inProgress;
      case 'failed':
        return GoalStatus.failed;
      case 'skipped':
        return GoalStatus.skipped;
      default:
        return GoalStatus.pending;
    }
  }

  static IconData _iconFromString(String v) {
    switch (v) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'reading':
        return Icons.auto_stories_rounded;
      case 'writing':
        return Icons.edit_rounded;
      case 'language':
        return Icons.language_rounded;
      case 'music':
        return Icons.music_note_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'period': period.name,
    'status': status.name,
    'progress': progress,
    'targetMinutes': targetMinutes,
    'completedMinutes': completedMinutes,
    'notificationEnabled': notificationEnabled,
    'category': category,
    'icon': icon.codePoint.toString(),
    'color': color.value,
  };
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  final _appState = AppState();
  late TabController _tabController;
  GoalPeriod _selectedPeriod = GoalPeriod.daily;
  List<GoalModel> _goals = [];

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChanged);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedPeriod = GoalPeriod.daily;
            break;
          case 1:
            _selectedPeriod = GoalPeriod.weekly;
            break;
          case 2:
            _selectedPeriod = GoalPeriod.monthly;
            break;
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGoals());
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PersistenceKeys.userGoals);
    if (raw == null || raw.isEmpty) {
      if (mounted) setState(() => _goals = []);
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final loaded = list
          .map((e) => GoalModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (mounted) setState(() => _goals = loaded);
    } catch (_) {
      if (mounted) setState(() => _goals = []);
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PersistenceKeys.userGoals,
      jsonEncode(_goals.map((g) => g.toMap()).toList()),
    );
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onStateChanged() => setState(() {});
  String _t(String key) => _appState.t(key);

  List<GoalModel> get _filteredGoals =>
      _goals.where((g) => g.period == _selectedPeriod).toList();

  int get _completedCount =>
      _filteredGoals.where((g) => g.status == GoalStatus.completed).length;

  double get _completionRate =>
      _filteredGoals.isEmpty ? 0 : _completedCount / _filteredGoals.length;

  void _showAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddGoalSheetWidget(
        selectedPeriod: _selectedPeriod,
        onAdd: (goal) {
          setState(() => _goals.add(goal));
          _saveGoals();
        },
      ),
    );
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
                  center: Alignment(-0.5, -0.5),
                  radius: 0.8,
                  colors: [Color(0x227C3AED), AppTheme.darkBackground],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                GoalsStatsHeaderWidget(
                  completedCount: _completedCount,
                  totalCount: _filteredGoals.length,
                  completionRate: _completionRate,
                  period: _selectedPeriod,
                ),
                const SizedBox(height: 8),
                _buildTabBar(),
                const SizedBox(height: 4),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGoalsList(GoalPeriod.daily, isTablet),
                      _buildGoalsList(GoalPeriod.weekly, isTablet),
                      _buildGoalsList(GoalPeriod.monthly, isTablet),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: _showAddGoalSheet,
          backgroundColor: AppTheme.primaryPink,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            _t('add_goal'),
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
          ),
          elevation: 0,
        ),
      ),
      bottomNavigationBar: AppNavigation(currentIndex: 1),
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
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withAlpha(31)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryPink, AppTheme.secondaryViolet],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(text: _t('daily')),
                Tab(text: _t('weekly')),
                Tab(text: _t('monthly')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsList(GoalPeriod period, bool isTablet) {
    final goals = _goals.where((g) => g.period == period).toList();
    if (goals.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.flag_rounded,
        title: 'No ${period.name.capitalize()} Goals Yet',
        subtitle:
            'Set your ${period.name} goals to track progress and build consistency.',
        ctaLabel: 'Create Goal',
        onCta: _showAddGoalSheet,
      );
    }
    if (isTablet) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: goals.length,
        itemBuilder: (context, i) => GoalCardWidget(
          goal: goals[i],
          index: i,
          onToggleNotification: (id) => _toggleNotification(id),
          onStatusChange: (id, status) => _changeStatus(id, status),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      itemCount: goals.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GoalCardWidget(
          goal: goals[i],
          index: i,
          onToggleNotification: (id) => _toggleNotification(id),
          onStatusChange: (id, status) => _changeStatus(id, status),
        ),
      ),
    );
  }

  void _toggleNotification(String id) {
    // TODO: Replace with Riverpod/Bloc for production
    setState(() {
      final idx = _goals.indexWhere((g) => g.id == id);
      if (idx != -1) {
        final g = _goals[idx];
        _goals[idx] = GoalModel(
          id: g.id,
          title: g.title,
          description: g.description,
          period: g.period,
          status: g.status,
          progress: g.progress,
          targetMinutes: g.targetMinutes,
          completedMinutes: g.completedMinutes,
          notificationEnabled: !g.notificationEnabled,
          category: g.category,
          icon: g.icon,
          color: g.color,
        );
      }
    });
    _saveGoals();
  }

  void _changeStatus(String id, GoalStatus status) {
    // TODO: Replace with Riverpod/Bloc for production
    setState(() {
      final idx = _goals.indexWhere((g) => g.id == id);
      if (idx != -1) {
        final g = _goals[idx];
        _goals[idx] = GoalModel(
          id: g.id,
          title: g.title,
          description: g.description,
          period: g.period,
          status: status,
          progress: status == GoalStatus.completed ? 1.0 : g.progress,
          targetMinutes: g.targetMinutes,
          completedMinutes: status == GoalStatus.completed
              ? g.targetMinutes
              : g.completedMinutes,
          notificationEnabled: g.notificationEnabled,
          category: g.category,
          icon: g.icon,
          color: g.color,
        );
      }
    });
    _saveGoals();
  }
}

extension StringExt on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
