import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Caytimer logo + title row for app bars (Focus, Goals, Blocking).
class CaytimerBrandHeader extends StatelessWidget {
  final String title;
  final double logoSize;

  const CaytimerBrandHeader({
    super.key,
    required this.title,
    this.logoSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo_cay.png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
