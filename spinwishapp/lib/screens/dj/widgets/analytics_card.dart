import 'package:flutter/material.dart';
import 'package:spinwishapp/utils/design_system.dart';

/// Model for sub-metrics displayed in analytics cards
class SubMetric {
  final String label;
  final String value;
  final IconData icon;
  final int? badge;

  const SubMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.badge,
  });
}

/// Analytics card widget for displaying session metrics
class AnalyticsCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final IconData icon;
  final Color color;
  final List<SubMetric> subMetrics;
  final VoidCallback? onTap;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.mainValue,
    required this.icon,
    required this.color,
    required this.subMetrics,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: SpinWishDesignSystem.paddingLG,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusLG),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: SpinWishDesignSystem.shadowMD(theme.colorScheme.shadow),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpinWishDesignSystem.spaceSM),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusSM),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                SpinWishDesignSystem.gapHorizontalSM,
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SpinWishDesignSystem.gapVerticalMD,
            
            // Main value
            Text(
              mainValue,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SpinWishDesignSystem.gapVerticalMD,
            
            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            
            SpinWishDesignSystem.gapVerticalMD,
            
            // Sub-metrics
            ...subMetrics.map((metric) => Padding(
              padding: const EdgeInsets.only(bottom: SpinWishDesignSystem.spaceSM),
              child: Row(
                children: [
                  Icon(
                    metric.icon,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SpinWishDesignSystem.gapHorizontalXS,
                  Text(
                    metric.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  if (metric.badge != null && metric.badge! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpinWishDesignSystem.spaceSM,
                        vertical: SpinWishDesignSystem.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(SpinWishDesignSystem.radiusFull),
                      ),
                      child: Text(
                        metric.badge.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Text(
                      metric.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

