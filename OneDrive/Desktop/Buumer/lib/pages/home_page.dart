import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class HomePage extends StatefulWidget {
  // main.dart'tan _logout() fonksiyonunu buraya alacağız
  final VoidCallback onLogout;
  
  const HomePage({super.key, required this.onLogout});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Çıkış yap fonksiyonunu ProfileScreen'e göndereceğiz
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const FeedScreen(),
      const MessagesScreen(),
      ProfileScreen(onLogout: widget.onLogout), // onLogout'u ProfileScreen'e pasla
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bu, bizim 3 sekmeli ana iskeletimiz
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buumer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Akış',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.tealAccent[400],
        onTap: _onItemTapped,
      ),
    );
  }
}