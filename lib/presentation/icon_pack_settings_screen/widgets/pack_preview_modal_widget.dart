import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PackPreviewModalWidget extends StatelessWidget {
  final Map<String, dynamic> pack;
  final VoidCallback onClose;

  const PackPreviewModalWidget({
    super.key,
    required this.pack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sampleIcons = (pack["sampleIcons"] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppTheme.elevationShadowHigh,
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack["name"] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${pack["iconCount"]} icons · ${pack["size"]}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppTheme.elevationShadowLow,
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: sampleIcons.length,
                itemBuilder: (context, index) {
                  final item = sampleIcons[index];
                  return _PreviewIconTile(
                    iconName: item["icon"] as String,
                    label: item["label"] as String,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: _ApplyPackButton(
              isInstalled: pack["installed"] as bool,
              onPressed: () {
                HapticFeedback.heavyImpact();
                onClose();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${pack["name"]} applied!'),
                    backgroundColor: AppTheme.primaryLight,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewIconTile extends StatefulWidget {
  final String iconName;
  final String label;
  const _PreviewIconTile({required this.iconName, required this.label});

  @override
  State<_PreviewIconTile> createState() => _PreviewIconTileState();
}

class _PreviewIconTileState extends State<_PreviewIconTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppTheme.animationFast);
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        _ctrl.forward();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.secondaryLight,
                    AppTheme.primaryLight,
                    AppTheme.primaryVariantLight,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryLight.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 2,
                    offset: const Offset(-1, -1),
                  ),
                ],
                border: Border.all(
                  color: AppTheme.secondaryLight.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Glossy highlight
                  Positioned(
                    top: 4,
                    left: 6,
                    right: 6,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: CustomIconWidget(
                      iconName: widget.iconName,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              widget.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplyPackButton extends StatelessWidget {
  final bool isInstalled;
  final VoidCallback onPressed;
  const _ApplyPackButton({required this.isInstalled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.8.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.secondaryLight,
                AppTheme.primaryLight,
                AppTheme.primaryVariantLight,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.elevationShadowMedium,
            border: Border.all(
              color: AppTheme.secondaryLight.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 4,
                left: 20,
                right: 20,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: isInstalled ? 'check_circle' : 'download',
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isInstalled ? 'Apply This Pack' : 'Install & Apply',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}