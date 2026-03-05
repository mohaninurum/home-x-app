import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DownloadPacksWidget extends StatelessWidget {
  const DownloadPacksWidget({super.key});

  static final List<Map<String, dynamic>> _featuredPacks = [
    {
      "name": "Jade Collection",
      "icons": 180,
      "price": "\$2.99",
      "rating": 4.8,
      "image":
      "https://img.rocket.new/generatedImages/rocket_gen_img_1188744a5-1772708755378.png",
      "semanticLabel":
      "Jade-colored gemstone collection representing premium icon pack",
    },
    {
      "name": "Bamboo Series",
      "icons": 120,
      "price": "Free",
      "rating": 4.5,
      "image":
      "https://img.rocket.new/generatedImages/rocket_gen_img_16d024b64-1772708753764.png",
      "semanticLabel": "Bamboo forest representing nature-themed icon series",
    },
    {
      "name": "Malachite UI",
      "icons": 250,
      "price": "\$4.99",
      "rating": 4.9,
      "image":
      "https://img.rocket.new/generatedImages/rocket_gen_img_1bf5e2240-1772708757276.png",
      "semanticLabel":
      "Malachite green mineral texture representing premium UI icon pack",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 22.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredPacks.length,
            separatorBuilder: (_, __) => SizedBox(width: 3.w),
            itemBuilder: (context, index) =>
                _FeaturedPackCard(pack: _featuredPacks[index]),
          ),
        ),
        SizedBox(height: 2.h),
        _MarketplaceButton(),
        SizedBox(height: 1.5.h),
        _StorageInfoCard(),
      ],
    );
  }
}

class _FeaturedPackCard extends StatefulWidget {
  final Map<String, dynamic> pack;
  const _FeaturedPackCard({required this.pack});

  @override
  State<_FeaturedPackCard> createState() => _FeaturedPackCardState();
}

class _FeaturedPackCardState extends State<_FeaturedPackCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppTheme.animationFast);
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
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
    final bool isFree = widget.pack["price"] == "Free";

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 42.w,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.elevationShadowLow,
            border: Border.all(
              color: AppTheme.primaryLight.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    CustomImageWidget(
                      imageUrl: widget.pack["image"] as String,
                      width: 42.w,
                      height: 12.h,
                      fit: BoxFit.cover,
                      semanticLabel: widget.pack["semanticLabel"] as String,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isFree
                              ? AppTheme.successColor
                              : AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.pack["price"] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pack["name"] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 0.3.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: AppTheme.warningColor,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.pack["rating"]}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${widget.pack["icons"]} icons',
                          style: theme.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
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

class _MarketplaceButton extends StatefulWidget {
  @override
  State<_MarketplaceButton> createState() => _MarketplaceButtonState();
}

class _MarketplaceButtonState extends State<_MarketplaceButton>
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
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        _ctrl.forward();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
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
                top: 3,
                left: 30,
                right: 30,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'store',
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Browse Icon Marketplace',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.elevationShadowLow,
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomIconWidget(
              iconName: 'storage',
              color: AppTheme.primaryLight,
              size: 22,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage Used by Icon Packs',
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.38,
                    backgroundColor: AppTheme.primaryLight.withValues(
                      alpha: 0.15,
                    ),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryLight,
                    ),
                    minHeight: 6,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text('83 MB of 220 MB used', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Unused packs cleaned up!'),
                  backgroundColor: AppTheme.primaryLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Clean',
                style: TextStyle(
                  color: AppTheme.errorLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
