import 'package:flutter/cupertino.dart';

class AppColors {
  // Brand Colors
  static const Color primary = CupertinoColors.activeBlue;
  static const Color success = CupertinoColors.activeGreen;
  static const Color expense = CupertinoColors.destructiveRed;
  static const Color income = CupertinoColors.activeGreen;
  static const Color warning = CupertinoColors.activeOrange;

  // Background colors
  static Color background(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF2F2F7);
  }

  static Color cardBackground(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFFFFFFF);
  }

  static Color label(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
  }

  static Color secondaryLabel(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF8E8E93);
  }

  static Color divider(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark
        ? const Color(0xFF38383A)
        : const Color(0xFFE5E5EA);
  }

  // Category specific premium colors (used for charts and indicators)
  static const Map<String, Color> categoryColors = {
    'Food & Drinks': Color(0xFFFF9500),      // Orange
    'Shopping': Color(0xFFAF52DE),           // Purple
    'Transportation': Color(0xFF5AC8FA),     // Teal
    'Entertainment': Color(0xFFFF2D55),      // Pink
    'Bills & Utilities': Color(0xFF5856D6),  // Indigo
    'Investment': Color(0xFF30D158),         // Mint Green
    'Salary': Color(0xFF34C759),             // Green
    'Side Hustle': Color(0xFF00C7BE),        // Teal-Green
    'Other': Color(0xFF8E8E93),              // Gray
  };

  static Color getCategoryColor(String name) {
    return categoryColors[name] ?? const Color(0xFF8E8E93);
  }

  // Linear gradients for a premium feel
  static const Gradient foodGradient = LinearGradient(
    colors: [Color(0xFFFFA21F), Color(0xFFFF9500)],
  );

  static const Gradient shoppingGradient = LinearGradient(
    colors: [Color(0xFFBF5AF2), Color(0xFFAF52DE)],
  );

  static const Gradient transportGradient = LinearGradient(
    colors: [Color(0xFF64D2FF), Color(0xFF5AC8FA)],
  );

  static const Gradient entertainmentGradient = LinearGradient(
    colors: [Color(0xFFFF375F), Color(0xFFFF2D55)],
  );

  static const Gradient billsGradient = LinearGradient(
    colors: [Color(0xFF5E5CE6), Color(0xFF5856D6)],
  );

  static const Gradient investmentGradient = LinearGradient(
    colors: [Color(0xFF30D158), Color(0xFF248A3D)],
  );

  static const Gradient salaryGradient = LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFF248A3D)],
  );

  static const Gradient sideHustleGradient = LinearGradient(
    colors: [Color(0xFF00C7BE), Color(0xFF00A29A)],
  );

  static Gradient getCategoryGradient(String name) {
    switch (name) {
      case 'Food & Drinks':
        return foodGradient;
      case 'Shopping':
        return shoppingGradient;
      case 'Transportation':
        return transportGradient;
      case 'Entertainment':
        return entertainmentGradient;
      case 'Bills & Utilities':
        return billsGradient;
      case 'Investment':
        return investmentGradient;
      case 'Salary':
        return salaryGradient;
      case 'Side Hustle':
        return sideHustleGradient;
      default:
        return LinearGradient(
          colors: [getCategoryColor(name), getCategoryColor(name).withOpacity(0.8)],
        );
    }
  }
}
