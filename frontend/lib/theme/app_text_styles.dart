import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle titleLarge = GoogleFonts.montserrat(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF6B3E2E),
  );

  static TextStyle titleMedium = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF6B3E2E),
  );

  static TextStyle body = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF5A5A5A),
  );

  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
