import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class IconPackCardWidget extends StatefulWidget {
  final Map<String, dynamic> pack;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  const IconPackCardWidget({
    super.key,
    required this.pack,
    required this.onToggle,
    required this.onTap,
  });

  @override
  State<IconPackCardWidget> createState() => _IconPackCardWidgetState();
}

class _IconPackCardWidgetState extends State<IconPackCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppTheme.animationFast);
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
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
    final bool isActive = widget.pack["active"] as bool;
    final bool isInstalled = widget.pack["installed"] as bool;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? AppTheme.elevationShadowMedium
                : AppTheme.elevationShadowLow,
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryLight.withValues(alpha: 0.6)
                  : AppTheme.primaryLight.withValues(alpha: 0.15),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThumbnailSection(pack: widget.pack, isActive: isActive),
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pack["name"] as String,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.4.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'apps',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 14,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '${widget.pack["iconCount"]} icons',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  SizedBox(width: 3.w),
                                  CustomIconWidget(
                                    iconName: 'storage',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 14,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    widget.pack["size"] as String,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        isInstalled
                            ? _SkeuomorphicToggle(
                          value: isActive,
                          onChanged: widget.onToggle,
                        )
                            : _InstallButton(
                          onPressed: () {
                            widget.onToggle(true);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        _StatusBadge(
                          isInstalled: isInstalled,
                          isActive: isActive,
                        ),
                        const Spacer(),
                        Text(
                          'Tap to preview',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primaryLight,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName: 'arrow_forward_ios',
                          color: AppTheme.primaryLight,
                          size: 12,
                        ),
                      ],
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

class _ThumbnailSection extends StatelessWidget {
  final Map<String, dynamic> pack;
  final bool isActive;

  const _ThumbnailSection({required this.pack, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 14.h,
            child: CustomImageWidget(
              imageUrl: pack["thumbnail"] as String,
              width: double.infinity,
              height: 14.h,
              fit: BoxFit.cover,
              semanticLabel: pack["semanticLabel"] as String,
            ),
          ),
          Container(
            width: double.infinity,
            height: 14.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.primaryVariantLight.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          if (isActive)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: AppTheme.elevationShadowLow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkeuomorphicToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SkeuomorphicToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: AppTheme.animationNormal,
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: value
              ? const LinearGradient(
            colors: [AppTheme.secondaryLight, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: value
                  ? AppTheme.primaryLight.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: value
                ? AppTheme.primaryVariantLight.withValues(alpha: 0.5)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: AppTheme.animationNormal,
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: AppTheme.elevationShadowLow,
              gradient: const RadialGradient(
                colors: [Colors.white, Color(0xFFE8E8E8)],
                center: Alignment(-0.3, -0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstallButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _InstallButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.secondaryLight, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppTheme.elevationShadowLow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'download',
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            const Text(
              'Install',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isInstalled;
  final bool isActive;
  const _StatusBadge({required this.isInstalled, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final Color color = isActive
        ? AppTheme.successColor
        : isInstalled
        ? AppTheme.primaryLight
        : AppTheme.warningColor;
    final String label = isActive
        ? 'Active'
        : isInstalled
        ? 'Installed'
        : 'Not Installed';
    final String iconName = isActive
        ? 'check_circle'
        : isInstalled
        ? 'inventory'
        : 'cloud_download';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: iconName, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
