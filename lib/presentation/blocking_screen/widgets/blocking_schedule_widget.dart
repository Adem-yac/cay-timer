import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_state.dart';
import '../../theme/app_theme.dart';

class BlockingScheduleModel {
  final String id;
  String startTime;
  String endTime;
  List<bool> days; // Mon-Sun
  bool isEnabled;

  BlockingScheduleModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.days,
    required this.isEnabled,
  });
}

class BlockingScheduleWidget extends StatefulWidget {
  const BlockingScheduleWidget({super.key});

  @override
  State<BlockingScheduleWidget> createState() => _BlockingScheduleWidgetState();
}

class _BlockingScheduleWidgetState extends State<BlockingScheduleWidget> {
  final _appState = AppState();
  final List<BlockingScheduleModel> _schedules = [
    BlockingScheduleModel(
      id: 'sched1',
      startTime: '09:00',
      endTime: '12:00',
      days: [true, true, true, true, true, false, false],
      isEnabled: true,
    ),
    BlockingScheduleModel(
      id: 'sched2',
      startTime: '14:00',
      endTime: '17:00',
      days: [true, true, true, true, true, false, false],
      isEnabled: false,
    ),
  ];

  String _t(String key) => _appState.t(key);

  final _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  void _addSchedule() {
    _showScheduleSheet(null);
  }

  void _editSchedule(BlockingScheduleModel schedule) {
    _showScheduleSheet(schedule);
  }

  void _deleteSchedule(String id) {
    setState(() => _schedules.removeWhere((s) => s.id == id));
  }

  void _showScheduleSheet(BlockingScheduleModel? existing) {
    String startTime = existing?.startTime ?? '09:00';
    String endTime = existing?.endTime ?? '18:00';
    List<bool> days = existing?.days.toList() ?? List.filled(7, true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface.withAlpha(230),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      existing == null ? _t('add_schedule') : 'Edit Schedule',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(
                            label: _t('start_time'),
                            time: startTime,
                            onTap: () async {
                              final parts = startTime.split(':');
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay(
                                  hour: int.parse(parts[0]),
                                  minute: int.parse(parts[1]),
                                ),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  startTime =
                                      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimePicker(
                            label: _t('end_time'),
                            time: endTime,
                            onTap: () async {
                              final parts = endTime.split(':');
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay(
                                  hour: int.parse(parts[0]),
                                  minute: int.parse(parts[1]),
                                ),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  endTime =
                                      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _t('days'),
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        return GestureDetector(
                          onTap: () => setSheetState(() => days[i] = !days[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: days[i]
                                  ? AppTheme.primaryPink
                                  : Colors.white.withAlpha(15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: days[i]
                                    ? AppTheme.primaryPink
                                    : Colors.white24,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _dayLabels[i],
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: days[i]
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Center(
                                child: Text(
                                  _t('cancel'),
                                  style: GoogleFonts.manrope(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (existing != null) {
                                  final idx = _schedules.indexWhere(
                                    (s) => s.id == existing.id,
                                  );
                                  if (idx != -1) {
                                    _schedules[idx].startTime = startTime;
                                    _schedules[idx].endTime = endTime;
                                    _schedules[idx].days = days;
                                  }
                                } else {
                                  _schedules.add(
                                    BlockingScheduleModel(
                                      id: 'sched_${DateTime.now().millisecondsSinceEpoch}',
                                      startTime: startTime,
                                      endTime: endTime,
                                      days: days,
                                      isEnabled: true,
                                    ),
                                  );
                                }
                              });
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                                  _t('save'),
                                  style: GoogleFonts.manrope(
                                    fontSize: 15,
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(fontSize: 11, color: Colors.white38),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.primaryPink,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _t('blocking_rules'),
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _addSchedule,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryPink, AppTheme.secondaryViolet],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _t('add_schedule'),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_schedules.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Center(
                child: Text(
                  'No blocking schedules yet',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: Colors.white38,
                  ),
                ),
              ),
            )
          else
            ..._schedules.map((schedule) => _buildScheduleCard(schedule)),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BlockingScheduleModel schedule) {
    final activeDays = schedule.days
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => _dayLabels[e.key])
        .join(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: schedule.isEnabled
            ? AppTheme.primaryPink.withAlpha(15)
            : Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.isEnabled
              ? AppTheme.primaryPink.withAlpha(80)
              : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${schedule.startTime} – ${schedule.endTime}',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
              const Spacer(),
              Switch(
                value: schedule.isEnabled,
                onChanged: (val) => setState(() => schedule.isEnabled = val),
                activeThumbColor: AppTheme.primaryPink,
                activeTrackColor: AppTheme.primaryPink.withAlpha(80),
                inactiveThumbColor: Colors.white38,
                inactiveTrackColor: Colors.white12,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white38,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                activeDays.isEmpty ? 'No days selected' : activeDays,
                style: GoogleFonts.manrope(fontSize: 12, color: Colors.white54),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _editSchedule(schedule),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white38,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _deleteSchedule(schedule.id),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}