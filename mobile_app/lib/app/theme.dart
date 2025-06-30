import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Brand Colors - Based on GACP natural and technology theme
  static const Color primaryGreen = Color(0xFF2E7D32);      // Forest Green
  static const Color secondaryGreen = Color(0xFF4CAF50);    // Lighter Green
  static const Color accentGold = Color(0xFFFF8F00);        // Amber Gold
  static const Color techBlue = Color(0xFF1976D2);          // Technology Blue
  static const Color warningAmber = Color(0xFFF57C00);      // Warning Amber
  static const Color errorRed = Color(0xFFD32F2F);          // Error Red
  static const Color successGreen = Color(0xFF388E3C);      // Success Green
  
  // Neutral Palette
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color outlineLight = Color(0xFFE0E0E0);
  
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color outlineDark = Color(0xFF404040);
  
  // Semantic Colors
  static const Color herbCannabis = Color(0xFF4CAF50);
  static const Color herbTurmeric = Color(0xFFFF9800);
  static const Color herbGinger = Color(0xFFFFEB3B);
  static const Color herbBlackGalingale = Color(0xFF795548);
  static const Color herbCassumunar = Color(0xFF9C27B0);
  static const Color herbKratom = Color(0xFF607D8B);
  
  // Quality Status Colors
  static const Color qualityExcellent = Color(0xFF00C853);
  static const Color qualityGood = Color(0xFF4CAF50);
  static const Color qualityFair = Color(0xFFFF9800);
  static const Color qualityPoor = Color(0xFFF44336);
  
  // Certificate Status Colors
  static const Color statusApproved = Color(0xFF4CAF50);
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusRejected = Color(0xFFF44336);
  static const Color statusDraft = Color(0xFF9E9E9E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE8F5E8),
        onPrimaryContainer: const Color(0xFF1B5E20),
        secondary: secondaryGreen,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFE8F5E8),
        onSecondaryContainer: const Color(0xFF1B5E20),
        tertiary: techBlue,
        onTertiary: Colors.white,
        error: errorRed,
        onError: Colors.white,
        errorContainer: const Color(0xFFFFEBEE),
        onErrorContainer: const Color(0xFFB71C1C),
        background: backgroundLight,
        onBackground: onSurfaceLight,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
        surfaceVariant: const Color(0xFFF5F5F5),
        onSurfaceVariant: const Color(0xFF6B6B6B),
        outline: outlineLight,
        outlineVariant: const Color(0xFFE8E8E8),
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        inverseSurface: const Color(0xFF2E2E2E),
        onInverseSurface: const Color(0xFFF0F0F0),
        inversePrimary: const Color(0xFF81C784),
        surfaceTint: primaryGreen,
      ),
      
      // Typography
      textTheme: _buildTextTheme(brightness: Brightness.light),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceLight,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
          fontFamily: 'Sarabun',
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(
          color: onSurfaceLight,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: surfaceLight,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceLight,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Color(0xFF757575),
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Sarabun',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: 'Sarabun',
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryGreen.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sarabun',
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sarabun',
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(88, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sarabun',
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sarabun',
          ),
        ),
      ),
      
      // FAB Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        splashColor: Colors.white24,
        shape: CircleBorder(),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF6B6B6B),
          fontSize: 16,
          fontFamily: 'Sarabun',
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 16,
          fontFamily: 'Sarabun',
        ),
        errorStyle: const TextStyle(
          color: errorRed,
          fontSize: 12,
          fontFamily: 'Sarabun',
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        elevation: 16,
        shadowColor: Colors.black.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceLight,
          fontFamily: 'Sarabun',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: onSurfaceLight,
          fontFamily: 'Sarabun',
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F5F5),
        selectedColor: primaryGreen.withOpacity(0.12),
        disabledColor: const Color(0xFFE0E0E0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          color: onSurfaceLight,
          fontSize: 14,
          fontFamily: 'Sarabun',
        ),
        secondaryLabelStyle: const TextStyle(
          color: primaryGreen,
          fontSize: 14,
          fontFamily: 'Sarabun',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearTrackColor: Color(0xFFE8F5E8),
        circularTrackColor: Color(0xFFE8F5E8),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGreen,
        inactiveTrackColor: primaryGreen.withOpacity(0.24),
        thumbColor: primaryGreen,
        overlayColor: primaryGreen.withOpacity(0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGreen;
          }
          return const Color(0xFFE0E0E0);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGreen.withOpacity(0.54);
          }
          return const Color(0xFFBDBDBD);
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGreen;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFFBDBDBD), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGreen;
          }
          return const Color(0xFFBDBDBD);
        }),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: outlineLight,
        thickness: 1,
        space: 16,
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minLeadingWidth: 40,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onSurfaceLight,
          fontFamily: 'Sarabun',
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: Color(0xFF6B6B6B),
          fontFamily: 'Sarabun',
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Sarabun',
        ),
        actionTextColor: primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceLight,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: primaryGreen,
        unselectedLabelColor: Color(0xFF6B6B6B),
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Sarabun',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'Sarabun',
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryGreen, width: 3),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme for Dark Theme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: secondaryGreen,
        onPrimary: Colors.black,
        primaryContainer: const Color(0xFF1B5E20),
        onPrimaryContainer: const Color(0xFFE8F5E8),
        secondary: primaryGreen,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFF2E7D32),
        onSecondaryContainer: const Color(0xFFE8F5E8),
        tertiary: const Color(0xFF64B5F6),
        onTertiary: Colors.black,
        error: const Color(0xFFEF5350),
        onError: Colors.black,
        errorContainer: const Color(0xFFB71C1C),
        onErrorContainer: const Color(0xFFFFEBEE),
        background: backgroundDark,
        onBackground: onSurfaceDark,
        surface: surfaceDark,
        onSurface: onSurfaceDark,
        surfaceVariant: const Color(0xFF2A2A2A),
        onSurfaceVariant: const Color(0xFFB0B0B0),
        outline: outlineDark,
        outlineVariant: const Color(0xFF505050),
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        inverseSurface: const Color(0xFFF0F0F0),
        onInverseSurface: const Color(0xFF2E2E2E),
        inversePrimary: primaryGreen,
        surfaceTint: secondaryGreen,
      ),
      
      // Typography for Dark Theme
      textTheme: _buildTextTheme(brightness: Brightness.dark),
      
      // AppBar Theme for Dark
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceDark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceDark,
          fontFamily: 'Sarabun',
        ),
        iconTheme: IconThemeData(
          color: onSurfaceDark,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: surfaceDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      
      // Bottom Navigation for Dark
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceDark,
        selectedItemColor: secondaryGreen,
        unselectedItemColor: Color(0xFF757575),
        elevation: 8,
      ),
      
      // Button themes for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryGreen,
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: secondaryGreen.withOpacity(0.3),
        ),
      ),
      
      // Card theme for dark
      cardTheme: CardTheme(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input decoration for dark
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFFB0B0B0),
          fontSize: 16,
          fontFamily: 'Sarabun',
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 16,
          fontFamily: 'Sarabun',
        ),
      ),
    );
  }

  // Helper method to build text theme
  static TextTheme _buildTextTheme({required Brightness brightness}) {
    final Color textColor = brightness == Brightness.light 
        ? onSurfaceLight 
        : onSurfaceDark;
    final Color secondaryTextColor = brightness == Brightness.light
        ? const Color(0xFF6B6B6B)
        : const Color(0xFFB0B0B0);

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.22,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.33,
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.33,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.38,
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: secondaryTextColor,
        fontFamily: 'Sarabun',
        height: 1.33,
      ),
      
      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: textColor,
        fontFamily: 'Sarabun',
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryTextColor,
        fontFamily: 'Sarabun',
        height: 1.27,
      ),
    );
  }

  // Custom gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, secondaryGreen],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB300), accentGold],
  );

  static const LinearGradient techGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [techBlue, Color(0xFF42A5F5)],
  );

  // Custom shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 3,
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 8),
      blurRadius: 12,
      spreadRadius: 6,
    ),
  ];

  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 8,
    ),
  ];
}

// Theme extensions for easy access
extension AppThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}

// Custom colors class for semantic meanings
class AppColors {
  static const Map<String, Color> herbColors = {
    'cannabis': AppTheme.herbCannabis,
    'turmeric': AppTheme.herbTurmeric,
    'ginger': AppTheme.herbGinger,
    'black_galingale': AppTheme.herbBlackGalingale,
    'cassumunar': AppTheme.herbCassumunar,
    'kratom': AppTheme.herbKratom,
  };

  static const Map<String, Color> qualityColors = {
    'excellent': AppTheme.qualityExcellent,
    'good': AppTheme.qualityGood,
    'fair': AppTheme.qualityFair,
    'poor': AppTheme.qualityPoor,
  };

  static const Map<String, Color> statusColors = {
    'approved': AppTheme.statusApproved,
    'pending': AppTheme.statusPending,
    'rejected': AppTheme.statusRejected,
    'draft': AppTheme.statusDraft,
  };

  static Color getHerbColor(String herbType) {
    return herbColors[herbType.toLowerCase()] ?? AppTheme.primaryGreen;
  }

  static Color getQualityColor(String quality) {
    return qualityColors[quality.toLowerCase()] ?? AppTheme.primaryGreen;
  }

  static Color getStatusColor(String status) {
    return statusColors[status.toLowerCase()] ?? AppTheme.primaryGreen;
  }
}