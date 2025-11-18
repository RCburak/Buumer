import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bu, "Mesajlar" sekmesinin içeriğidir
    return const Center(
      child: Text(
        'Mesajlar',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
