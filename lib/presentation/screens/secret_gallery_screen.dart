import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../theme_provider.dart';
import 'package:local_auth/local_auth.dart';

class SecretGalleryScreen extends ConsumerStatefulWidget {
  const SecretGalleryScreen({super.key});

  @override
  ConsumerState<SecretGalleryScreen> createState() => _SecretGalleryScreenState();
}

class _SecretGalleryScreenState extends ConsumerState<SecretGalleryScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  List<File> _secretPhotos = [];

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Unlock your private memory gallery',
        biometricOnly: false,
      );
      if (didAuthenticate) {
        setState(() {
          _isAuthenticated = true;
        });
        _loadSecretPhotos();
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _loadSecretPhotos() async {
    final directory = await getApplicationDocumentsDirectory();
    final secretDir = Directory('${directory.path}/secret_gallery');
    
    if (await secretDir.exists()) {
      final List<FileSystemEntity> entities = secretDir.listSync();
      setState(() {
        _secretPhotos = entities.whereType<File>().toList();
      });
    } else {
      await secretDir.create();
    }
  }

  Future<void> _addPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String secretPath = '${directory.path}/secret_gallery/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final File newFile = await File(image.path).copy(secretPath);
      
      // Optionally delete from public gallery for true "hide" behavior, skipping for demo safety
      
      setState(() {
        _secretPhotos.add(newFile);
      });
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

    final theme = ref.watch(themeMoodProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Secret Gallery', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: _addPhoto,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
      body: _secretPhotos.isEmpty
          ? const Center(child: Text("No secret memories yet 🔒", style: TextStyle(color: Colors.white54)))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _secretPhotos.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_secretPhotos[index], fit: BoxFit.cover),
                );
              },
            ),
    );
  }
}
