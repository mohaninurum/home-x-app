import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme_provider.dart';

class CoupleGoalsWidget extends ConsumerStatefulWidget {
  const CoupleGoalsWidget({super.key});

  @override
  ConsumerState<CoupleGoalsWidget> createState() => _CoupleGoalsWidgetState();
}

class _CoupleGoalsWidgetState extends ConsumerState<CoupleGoalsWidget> {
  final DateTime nextAnniversary = DateTime(DateTime.now().year, 12, 31); // Mock data

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeMoodProvider);
    final int daysLeft = nextAnniversary.difference(DateTime.now()).inDays;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.secondaryColor.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.monitor_heart, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text("Couple Goals", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          _buildGoalRow(context, Icons.event, "Anniversary in", "$daysLeft days"),
          const SizedBox(height: 8),
          _buildGoalRow(context, Icons.restaurant, "Next Date Night", "Friday 8 PM"),
          const SizedBox(height: 8),
          _buildGoalRow(context, Icons.card_giftcard, "Gift Idea", "Necklace stored"),
        ],
      ),
    );
  }

  Widget _buildGoalRow(BuildContext context, IconData icon, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
