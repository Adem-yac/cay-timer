import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../blocking_screen.dart';

class BlockDurationSheetWidget extends StatefulWidget {
  final AppBlockModel app;
  final void Function(int durationMinutes) onSave;

  const BlockDurationSheetWidget({
    super.key,
    required this.app,
    required this.onSave,
  });

  @override
  State<BlockDurationSheetWidget> createState() =>
      _BlockDurationSheetWidgetState();
}

class _BlockDurationSheetWidgetState extends State<BlockDurationSheetWidget> {
  late int _selectedDuration;
  bool _blockDuringFocus = true;
  bool _scheduleEnabled = false;
  String _scheduleStart = '09:00';
  String _scheduleEnd = '17:00';

  final _durations = [
    {'label': '15m', 'value': 15},
    {'label': '30m', 'value': 30},
    {'label': '45m', 'value': 45},
    {'label': '1h', 'value': 60},
    {'label': '1.5h', 'value': 90},
    {'label': '2h', 'value': 120},
    {'label': '3h', 'value': 180},
    {'label': '4h', 'value': 240},
    {'label': 'All Day', 'value': 480},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.app.blockDurationMinutes;
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withAlpha(247),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.app.iconColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.app.icon,
                        color: widget.app.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.app.name,
                          style: GoogleFonts.manrope(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.app.category,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Block Duration',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _durations.map((d) {
                    final val = d['value'] as int;
                    final isSelected = _selectedDuration == val;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDuration = val),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    AppTheme.primaryPink,
                                    AppTheme.secondaryViolet,
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white.withAlpha(26),
                          ),
                        ),
                        child: Text(
                          d['label'] as String,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected ? Colors.white : Colors.white54,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _buildToggleRow(
                  Icons.timer_rounded,
                  'Block During Focus Sessions',
                  'App is blocked when a focus session is active',
                  _blockDuringFocus,
                  (v) => setState(() => _blockDuringFocus = v),
                  AppTheme.primaryPink,
                ),
                const SizedBox(height: 12),
                _buildToggleRow(
                  Icons.schedule_rounded,
                  'Schedule Block',
                  'Block automatically at scheduled times',
                  _scheduleEnabled,
                  (v) => setState(() => _scheduleEnabled = v),
                  AppTheme.secondaryViolet,
                ),
                if (_scheduleEnabled) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeField('Start Time', _scheduleStart, (
                          v,
                        ) {
                          setState(() => _scheduleStart = v);
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeField('End Time', _scheduleEnd, (v) {
                          setState(() => _scheduleEnd = v);
                        }),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(_selectedDuration);
                      Navigator.pop(context);
                    },
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
                          'Save Block Settings',
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
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    void Function(bool) onChanged,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(31),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField(
    String label,
    String value,
    void Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: Colors.white38,
            size: 16,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(fontSize: 10, color: Colors.white38),
              ),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}