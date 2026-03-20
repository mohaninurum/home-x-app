import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class HiddenAppsScreen extends ConsumerStatefulWidget {
  const HiddenAppsScreen({super.key});

  @override
  ConsumerState<HiddenAppsScreen> createState() => _HiddenAppsScreenState();
}

class _HiddenAppsScreenState extends ConsumerState<HiddenAppsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access Private Space',
        biometricOnly: false,
      );
      setState(() {
        _isAuthenticated = didAuthenticate;
      });
      if (!didAuthenticate) {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth error: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(
        backgroundColor: Colors.black87,
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    final appsAsync = ref.watch(appsProvider);
    final hiddenPackages = ref.watch(hiddenAppsProvider).value ?? {};

    return Scaffold(
      backgroundColor: Colors.black87, // Dark elegant background for hidden space
      appBar: AppBar(
        title: const Text('Secret Space', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
      ),
      body: appsAsync.when(
        data: (apps) {
          final hiddenApps = apps.where((app) => hiddenPackages.contains(app.packageName)).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: hiddenApps.length,
            itemBuilder: (context, index) {
              final app = hiddenApps[index];
              return InkWell(
                onTap: () {
                  ref.read(nativeAppServiceProvider).launchApp(app.packageName);
                },
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.black87,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.visibility_outlined, color: Colors.pinkAccent),
                            title: const Text('Unhide App', style: TextStyle(color: Colors.white)),
                            onTap: () {
                              ref.read(hiddenAppsProvider.notifier).unhideApp(app.packageName);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${app.label} visible in Drawer'),
                                  backgroundColor: Colors.pinkAccent,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.memory(app.iconBytes, width: 48, height: 48),
                    const SizedBox(height: 4),
                    Text(
                      app.label,
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
