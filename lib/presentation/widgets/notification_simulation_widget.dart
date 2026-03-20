import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme_provider.dart';
import '../../core/responsive_utils.dart';

class NotificationSimulationWidget extends ConsumerStatefulWidget {
  const NotificationSimulationWidget({super.key});

  @override
  ConsumerState<NotificationSimulationWidget> createState() => _NotificationSimulationWidgetState();
}

class _NotificationSimulationWidgetState extends ConsumerState<NotificationSimulationWidget> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    
    // Simulate a romantic notification arriving after 5 seconds for demonstration
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isVisible = true);
        _controller.forward();
        
        // Auto dismiss after 4 seconds
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            _controller.reverse().then((_) {
              if (mounted) setState(() => _isVisible = false);
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final theme = ref.watch(themeMoodProvider);
    
    return Positioned(
      top: 50.sh(context), // Below status bar
      left: 20.sw(context),
      right: 20.sw(context),
      child: FadeTransition(
        opacity: _controller,
        child: ScaleTransition(
          scale: _animation,
          child: Container(
            padding: EdgeInsets.all(16.sw(context)),
            decoration: BoxDecoration(
              color: theme.backgroundColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20.sw(context)),
              border: Border.all(color: theme.primaryColor, width: 2.sw(context)),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.5),
                  blurRadius: 15.sw(context),
                  spreadRadius: 2.sw(context),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.sw(context)),
                  decoration: BoxDecoration(
                    color: theme.secondaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite, color: theme.primaryColor, size: 24.sw(context)),
                ),
                SizedBox(width: 15.sw(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "New message from your love 💌",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.wsp(context),
                        ),
                      ),
                      SizedBox(height: 4.sw(context)),
                      Text(
                        "Are we still on for tonight? ❤️",
                        style: TextStyle(
                          color: theme.primaryColor.withOpacity(0.8),
                          fontSize: 12.wsp(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
