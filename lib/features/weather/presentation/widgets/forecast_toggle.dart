import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'glass_container.dart';

enum ForecastViewMode { hourly, daily }

/// Sélecteur segmented control en forme de pilule (Fonctionnalité 7).
///
/// Permet de basculer entre :
/// - "Par heure" (prévisions horaires)
/// - "Quotidien" (prévisions 5 jours)
class ForecastToggle extends StatelessWidget {
  const ForecastToggle({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final ForecastViewMode selectedMode;
  final ValueChanged<ForecastViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(30),
      backgroundColor: GlassStyles.glassBackground(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleItem(
            title: 'Par heure',
            icon: Icons.access_time_filled_rounded,
            isSelected: selectedMode == ForecastViewMode.hourly,
            onTap: () => onModeChanged(ForecastViewMode.hourly),
          ),
          _ToggleItem(
            title: 'Quotidien',
            icon: Icons.calendar_month_rounded,
            isSelected: selectedMode == ForecastViewMode.daily,
            onTap: () => onModeChanged(ForecastViewMode.daily),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.35))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white60,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
