import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum CustomAppBarVariant { primary, transparent, surface }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double elevation;
  final Widget? titleWidget;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.primary,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation = 4.0,
    this.titleWidget,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;

    switch (variant) {
      case CustomAppBarVariant.primary:
        bgColor = isDark ? AppTheme.surfaceDark : AppTheme.primaryLight;
        fgColor = isDark ? AppTheme.onSurfaceDark : AppTheme.onPrimaryLight;
        break;
      case CustomAppBarVariant.transparent:
        bgColor = Colors.transparent;
        fgColor = isDark ? AppTheme.onSurfaceDark : AppTheme.onSurfaceLight;
        break;
      case CustomAppBarVariant.surface:
        bgColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
        fgColor = isDark ? AppTheme.onSurfaceDark : AppTheme.onSurfaceLight;
        break;
    }

    return Container(
      decoration: variant != CustomAppBarVariant.transparent
          ? BoxDecoration(
        color: bgColor,
        boxShadow: elevation > 0 ? AppTheme.elevationShadowMedium : null,
      )
          : null,
      child: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: fgColor,
        elevation: 0,
        centerTitle: centerTitle,
        leading:
        leading ??
            (showBackButton && Navigator.canPop(context)
                ? _SkeuomorphicBackButton(
              color: fgColor,
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
                : null),
        title:
        titleWidget ??
            (title != null
                ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            )
                : null),
        actions: actions,
      ),
    );
  }
}

class _SkeuomorphicBackButton extends StatefulWidget {
  final Color color;
  final VoidCallback onPressed;

  const _SkeuomorphicBackButton({required this.color, required this.onPressed});

  @override
  State<_SkeuomorphicBackButton> createState() =>
      _SkeuomorphicBackButtonState();
}

class _SkeuomorphicBackButtonState extends State<_SkeuomorphicBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.animationFast,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppTheme.elevationShadowLow,
            border: Border.all(
              color: widget.color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: widget.color,
            size: 18,
          ),
        ),
      ),
    );
  }
}
