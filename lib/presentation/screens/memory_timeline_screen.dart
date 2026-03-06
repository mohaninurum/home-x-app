import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme_provider.dart';

class MemoryTimelineScreen extends ConsumerStatefulWidget {
  const MemoryTimelineScreen({super.key});

  @override
  ConsumerState<MemoryTimelineScreen> createState() => _MemoryTimelineScreenState();
}

class _MemoryTimelineScreenState extends ConsumerState<MemoryTimelineScreen> {
  final List<Map<String, String>> _memories = [
    {"year": "2023", "event": "First Meet ❤️", "description": "The day it all began."},
    {"year": "2024", "event": "First Trip 🌹", "description": "Our unforgettable vacation."},
    {"year": "2025", "event": "Engagement 💍", "description": "A promise of forever."},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeMoodProvider);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text("Memory Timeline", style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _memories.length,
        itemBuilder: (context, index) {
          final memory = _memories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index != _memories.length - 1)
                      Container(
                        width: 2,
                        height: 60,
                        color: theme.primaryColor.withOpacity(0.5),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${memory['year']} – ${memory['event']}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        memory['description']!,
                        style: TextStyle(fontSize: 14, color: theme.primaryColor.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
