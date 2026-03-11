import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../widgets/floating_app_icon.dart';

class AppPickerDialog extends ConsumerWidget {
  const AppPickerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsProvider);
    final theme = ref.watch(themeMoodProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select App for Widget',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: appsAsync.when(
              data: (apps) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, app.packageName);
                    },
                    child: Column(
                      children: [
                        Expanded(child: AppIconContent(app: app)),
                        const SizedBox(height: 4),
                        Text(
                          app.label,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
