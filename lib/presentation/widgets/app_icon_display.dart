import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Shows a real app icon (Android) or a fallback [IconData].
class AppIconDisplay extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color iconColor;
  final Uint8List? iconBytes;

  const AppIconDisplay({
    super.key,
    required this.size,
    required this.icon,
    required this.iconColor,
    this.iconBytes,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = iconBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: iconColor.withAlpha(38),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.5),
    );
  }
}
