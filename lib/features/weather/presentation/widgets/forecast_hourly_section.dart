import 'package:flutter/material.dart';
import '../../domain/entities/forecast_day.dart';
import '../../domain/entities/forecast_hour.dart';
import 'forecast_toggle.dart';
import 'glass_container.dart';
import 'weather_glyph.dart';

/// Section des prévisions horaires scrollable horizontalement (Fonctionnalité 6).
class ForecastHourlySection extends StatelessWidget {
  const ForecastHourlySection({super.key, required this.hours});

  final List<ForecastHour> hours;

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 146,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: hours.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final hour = hours[index];
          final popPercent = (hour.pop * 100).round();
          final timeStr = '${hour.dateTime.hour.toString().padLeft(2, '0')}h';

          return GlassContainer(
            width: 88,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Heure
                Text(
                  timeStr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Icône
                WeatherGlyph(iconCode: hour.iconCode, size: 38),

                // Température
                Text(
                  '${hour.temperature.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // Risque de pluie si présent
                if (popPercent > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        size: 11,
                        color: Colors.lightBlueAccent.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$popPercent%',
                        style: TextStyle(
                          color: Colors.lightBlueAccent.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 14),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Section des prévisions quotidiennes (5 jours).
class ForecastDailySection extends StatelessWidget {
  const ForecastDailySection({super.key, required this.days});

  final List<ForecastDay> days;

  static const List<String> _weekdays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        children: days.map((day) {
          final weekdayName = _weekdays[day.date.weekday - 1];
          final dateStr = '${day.date.day}/${day.date.month}';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Jour
                SizedBox(
                  width: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weekdayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Icône + description
                WeatherGlyph(iconCode: day.iconCode, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    day.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Min / Max
                Text(
                  '${day.tempMin.round()}° / ${day.tempMax.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Conteneur combiné des prévisions avec le Toggle (Fonctionnalité 6 & 7).
class ForecastSectionView extends StatefulWidget {
  const ForecastSectionView({
    super.key,
    required this.hours,
    required this.days,
  });

  final List<ForecastHour> hours;
  final List<ForecastDay> days;

  @override
  State<ForecastSectionView> createState() => _ForecastSectionViewState();
}

class _ForecastSectionViewState extends State<ForecastSectionView> {
  ForecastViewMode _mode = ForecastViewMode.hourly;

  @override
  Widget build(BuildContext context) {
    if (widget.hours.isEmpty && widget.days.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre + Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Prévisions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            ForecastToggle(
              selectedMode: _mode,
              onModeChanged: (mode) {
                setState(() {
                  _mode = mode;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Transition animée entre vue horaire et vue quotidienne
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _mode == ForecastViewMode.hourly
              ? ForecastHourlySection(
                  key: const ValueKey('hourly_section'),
                  hours: widget.hours,
                )
              : ForecastDailySection(
                  key: const ValueKey('daily_section'),
                  days: widget.days,
                ),
        ),
      ],
    );
  }
}
