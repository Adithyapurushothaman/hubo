import 'package:flutter/material.dart';

/// Central color palette for the app.
/// Adjust these values to tune the visual theme.
abstract class Palette {
  // Primary app color (green-teal)
  static const Color primary = Color(0xFF2BB673);

  // Secondary / accent (blue)
  static const Color secondary = Color(0xFF2E9BFF);

  // A lighter accent for surfaces
  static const Color accent = Color(0xFF6EE7B7);

  // Text on primary colored buttons
  static const Color onPrimary = Colors.white;

  // Surface background (white)
  static const Color surface = Colors.white;

  // Card background
  static final Color card = Colors.white;
}

// A small Gradient helper if you want to use gradients for logo/button
final Gradient primaryGradient = const LinearGradient(
  colors: [Palette.primary, Palette.secondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
