import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_provider.dart';

class LoveNotesWidget extends ConsumerStatefulWidget {
  const LoveNotesWidget({super.key});

  @override
  ConsumerState<LoveNotesWidget> createState() => _LoveNotesWidgetState();
}

class _LoveNotesWidgetState extends ConsumerState<LoveNotesWidget> {
  String _currentNote = "❤️ I miss you";
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentNote = prefs.getString('love_note') ?? "❤️ I miss you";
    });
  }

  Future<void> _saveNote(String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('love_note', note);
    setState(() {
      _currentNote = note;
    });
  }

  void _editNote() {
    _controller.text = _currentNote;
    showDialog(
      context: context,
      builder: (context) {
        final theme = ref.read(themeMoodProvider);
        return AlertDialog(
          backgroundColor: theme.backgroundColor,
          title: Text("Edit Love Note", style: TextStyle(color: theme.primaryColor)),
          content: TextField(
            controller: _controller,
            style: TextStyle(color: theme.primaryColor),
            decoration: InputDecoration(
              hintText: "Enter note...",
              hintStyle: TextStyle(color: theme.primaryColor.withOpacity(0.5)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: theme.primaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              onPressed: () {
                _saveNote(_controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeMoodProvider);

    return GestureDetector(
      onTap: _editNote,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: theme.backgroundColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note, color: theme.primaryColor, size: 18),
            const SizedBox(width: 8),
            Text(
              _currentNote,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
