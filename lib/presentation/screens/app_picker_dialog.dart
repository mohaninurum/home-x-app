import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../widgets/floating_app_icon.dart';
import '../../core/responsive_utils.dart';

class AppPickerDialog extends ConsumerStatefulWidget {
  const AppPickerDialog({super.key});

  @override
  ConsumerState<AppPickerDialog> createState() => _AppPickerDialogState();
}

class _AppPickerDialogState extends ConsumerState<AppPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(appsProvider);
    final theme = ref.watch(themeMoodProvider);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40.sw(context))),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.backgroundColor.withOpacity(0.65),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.sw(context))),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5.sw(context),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.2), 
                blurRadius: 40.sw(context), 
                spreadRadius: 5.sw(context)
              ),
            ],
          ),
          child: Column(
            children: [
              // Premium Header & Search Bar
              Container(
                padding: EdgeInsets.only(
                  top: 15.sh(context),
                  bottom: 20.sh(context),
                  left: 25.sw(context),
                  right: 25.sw(context),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 50.sw(context),
                      height: 5.sh(context),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.sw(context)),
                      ),
                    ),
                    SizedBox(height: 20.sh(context)),
                    Row(
                      children: [
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [theme.primaryColor, Colors.white],
                            ).createShader(bounds),
                              child: Text(
                                'Add to Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.wsp(context),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5.sw(context),
                                ),
                              ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white70, size: 24.sw(context)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sh(context)),
                    
                    // Search Bar
                    Container(
                      height: 50.sh(context),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25.sw(context)),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search apps...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14.wsp(context)),
                          prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20.sw(context)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14.sh(context)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.white54, size: 20.sw(context)),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = "";
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // App Grid
              Expanded(
                child: appsAsync.when(
                  data: (allApps) {
                    final apps = allApps.where((app) => 
                      app.label.toLowerCase().contains(_searchQuery)).toList();

                    if (apps.isEmpty) {
                      return const Center(
                        child: Text(
                          "No apps found",
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(20.sw(context), 10.sh(context), 20.sw(context), 40.sh(context)),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 25.sh(context),
                        crossAxisSpacing: 15.sw(context),
                        childAspectRatio: 0.7,
                      ),
                      itemCount: apps.length,
                      itemBuilder: (context, index) {
                        final app = apps[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index % 10 * 30)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Opacity(
                                opacity: value.clamp(0.0, 1.0),
                                child: child,
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context, app.packageName),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(0.15),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    ),
                                    child: AppIconContent(app: app, size: 55.sw(context)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: theme.primaryColor,
                      strokeWidth: 3,
                    ),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Failed to load apps: $err',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
