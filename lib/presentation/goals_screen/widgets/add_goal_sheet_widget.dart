import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import './goals_stats_header_widget.dart';
import '../../widgets/status_badge_widget.dart';

class AddGoalSheetWidget extends StatefulWidget {
  final GoalPeriod selectedPeriod;
  final void Function(GoalModel goal) onAdd;

  const AddGoalSheetWidget({
    super.key,
    required this.selectedPeriod,
    required this.onAdd,
  });

  @override
  State<AddGoalSheetWidget> createState() => _AddGoalSheetWidgetState();
}

class _AddGoalSheetWidgetState extends State<AddGoalSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late GoalPeriod _period;
  int _targetMinutes = 30;
  bool _notificationEnabled = true;
  final String _selectedCategory = 'Productivity';
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;

  final _icons = [
    Icons.code_rounded,
    Icons.menu_book_rounded,
    Icons.fitness_center_rounded,
    Icons.self_improvement_rounded,
    Icons.edit_rounded,
    Icons.language_rounded,
    Icons.music_note_rounded,
    Icons.flag_rounded,
  ];
  final _colors = [
    AppTheme.primaryPink,
    AppTheme.secondaryViolet,
    AppTheme.accentBlueBright,
    AppTheme.success,
    AppTheme.warning,
    AppTheme.error,
  ];

  @override
  void initState() {
    super.initState();
    _period = widget.selectedPeriod;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final goal = GoalModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        period: _period,
        status: GoalStatus.pending,
        progress: 0,
        targetMinutes: _targetMinutes,
        completedMinutes: 0,
        notificationEnabled: _notificationEnabled,
        category: _selectedCategory,
        icon: _icons[_selectedIconIndex],
        color: _colors[_selectedColorIndex],
      );
      widget.onAdd(goal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withAlpha(247),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'New Goal',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Period selector
                    Row(
                      children: GoalPeriod.values.map((p) {
                        final isSelected = _period == p;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _period = p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          AppTheme.primaryPink,
                                          AppTheme.secondaryViolet,
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.white.withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white.withAlpha(26),
                                ),
                              ),
                              child: Text(
                                p.name.capitalize(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white38,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Goal Title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Deep Work Session',
                        hintStyle: GoogleFonts.manrope(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white.withAlpha(15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(26),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(26),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryPink,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.error,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.error,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Title required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Description'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Describe your goal...',
                        hintStyle: GoogleFonts.manrope(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Colors.white.withAlpha(15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(26),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(26),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryPink,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Target Duration'),
                    const SizedBox(height: 8),
                    Row(
                      children: [15, 30, 45, 60, 90, 120].map((m) {
                        final isSelected = _targetMinutes == m;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _targetMinutes = m),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryPink.withAlpha(51)
                                    : Colors.white.withAlpha(13),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryPink
                                      : Colors.white.withAlpha(20),
                                ),
                              ),
                              child: Text(
                                m >= 60 ? '${m ~/ 60}h' : '${m}m',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppTheme.primaryPink
                                      : Colors.white38,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Icon'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _icons.length,
                        itemBuilder: (_, i) {
                          final isSelected = _selectedIconIndex == i;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIconIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 10),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryPink.withAlpha(51)
                                    : Colors.white.withAlpha(13),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryPink
                                      : Colors.white.withAlpha(20),
                                ),
                              ),
                              child: Icon(
                                _icons[i],
                                color: isSelected
                                    ? AppTheme.primaryPink
                                    : Colors.white38,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Color'),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(_colors.length, (i) {
                        final isSelected = _selectedColorIndex == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColorIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 10),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _colors[i],
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2.5)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Send Notifications',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Alert when goal is not yet completed',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _notificationEnabled,
                          onChanged: (v) =>
                              setState(() => _notificationEnabled = v),
                          activeThumbColor: AppTheme.primaryPink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryPink,
                                AppTheme.secondaryViolet,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              'Create Goal',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: GoogleFonts.manrope(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.white54,
    ),
  );
}
