import 'package:flutter/material.dart';

/// Centralised design tokens for the whole app.
///
/// Keeping colors, gradients and shared decorations in one place means
/// every screen automatically stays visually consistent, and re-skinning
/// the app later only means editing this file.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1E3A8A); // deep blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF0EA5E9);

  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);

  static const Color background = Color(0xFFF3F4F6);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// One accent gradient per dashboard module so cards read distinctly
  /// without every screen inventing its own palette.
  static const List<List<Color>> moduleGradients = [
    [Color(0xFFF97316), Color(0xFFFB923C)], // orange – costing
    [Color(0xFF16A34A), Color(0xFF4ADE80)], // green – accessories
    [Color(0xFF9333EA), Color(0xFFC084FC)], // purple – chalan
    [Color(0xFF0D9488), Color(0xFF2DD4BF)], // teal – document submit
    [Color(0xFF2563EB), Color(0xFF60A5FA)], // blue – requested customer
  ];



  static Color get error => Color(0xFFDC2626);
  static Color get divider => Color(0xFFE5E7EB);

}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
}

class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

/// Shared page transition: fade + slight upward slide, used from
/// [AppTheme.pageRoute] so navigation feels consistent across the app.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// A fade+slide page route so screen-to-screen navigation feels smooth
  /// everywhere without repeating transition code in every screen.
  static Route<T> pageRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
