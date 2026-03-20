import 'package:flutter/material.dart';
import '../../core/responsive_utils.dart';

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
            CircleAvatar(
              radius: 60.sw(context),
              backgroundColor: Colors.pinkAccent,
              child: Icon(Icons.favorite, size: 60.sw(context), color: Colors.white),
            ),
            SizedBox(height: 30.sh(context)),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening WhatsApp...')));
              },
              icon: const Icon(Icons.chat),
              label: const Text('Quick Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30.sw(context), vertical: 15.sh(context)),
              ),
            ),
            SizedBox(height: 15.sh(context)),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling Partner...')));
              },
              icon: const Icon(Icons.call),
              label: const Text('Call Partner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30.sw(context), vertical: 15.sh(context)),
              ),
            ),
            SizedBox(height: 50.sh(context)),
            Text(
              "Our Memories",
              style: TextStyle(fontSize: 20.wsp(context), fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            SizedBox(height: 20.sh(context)),
            // Placeholder for Shared Photos
            Container(
              height: 150.sh(context),
              width: 250.sw(context),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(15.sw(context)),
                border: Border.all(color: Colors.pink.shade200, width: 2.sw(context)),
              ),
              child: Center(
                child: Text('Add Anniversary Photo Here', style: TextStyle(color: Colors.pink, fontSize: 14.wsp(context))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
