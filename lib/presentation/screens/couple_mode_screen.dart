import 'package:flutter/material.dart';

class CoupleModeScreen extends StatelessWidget {
  const CoupleModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Us ❤️"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.pinkAccent,
              child: Icon(Icons.favorite, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening WhatsApp...')));
              },
              icon: const Icon(Icons.chat),
              label: const Text('Quick Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling Partner...')));
              },
              icon: const Icon(Icons.call),
              label: const Text('Call Partner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              "Our Memories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            const SizedBox(height: 20),
            // Placeholder for Shared Photos
            Container(
              height: 150,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.pink.shade200, width: 2),
              ),
              child: const Center(
                child: Text('Add Anniversary Photo Here', style: TextStyle(color: Colors.pink)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
