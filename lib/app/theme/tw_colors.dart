import 'package:flutter/material.dart';

/// TradeWise light/dark color tokens.
///
/// These are provisional foundation values only. The final TradeWise visual
/// identity will be refined during the Welcome implementation after analyzing
/// the supplied Welcome references. The [primary] color is a restrained
/// placeholder and must NOT be treated as the final brand color.
abstract final class TWColors {
  // Light scheme.
  static const Color lightBackgroundPrimary = Color(0xFFF7F8FA);
  static const Color lightBackgroundSecondary = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F3F6);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextTertiary = Color(0xFF6B7280);
  static const Color lightTextDisabled = Color(0xFF9CA3AF);
  static const Color lightPositive = Color(0xFF15803D);
  static const Color lightNegative = Color(0xFFDC2626);
  static const Color lightNeutral = Color(0xFF64748B);
  static const Color lightWarning = Color(0xFFB45309);

  /// Provisional primary. See class docs.
  static const Color lightPrimary = Color(0xFF2563EB);
  static const Color lightPrimaryVariant = Color(0xFF1D4ED8);

  // Dark scheme.
  static const Color darkBackgroundPrimary = Color(0xFF0B0F14);
  static const Color darkBackgroundSecondary = Color(0xFF11161D);
  static const Color darkSurface = Color(0xFF151C24);
  static const Color darkSurfaceElevated = Color(0xFF1E2833);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkTextDisabled = Color(0xFF64748B);
  static const Color darkPositive = Color(0xFF4ADE80);
  static const Color darkNegative = Color(0xFFF87171);
  static const Color darkNeutral = Color(0xFF94A3B8);
  static const Color darkWarning = Color(0xFFFBBF24);

  /// Provisional primary (dark). See class docs.
  static const Color darkPrimary = Color(0xFF60A5FA);
  static const Color darkPrimaryVariant = Color(0xFF3B82F6);
}
