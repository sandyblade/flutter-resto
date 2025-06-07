import 'package:flutter/material.dart';

class MainAppPage extends StatelessWidget {
  const MainAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyMainAppPage());
  }
}

class MyMainAppPage extends StatefulWidget {
  const MyMainAppPage({super.key});

  @override
  _MyMainAppPageState createState() => _MyMainAppPageState();
}

class _MyMainAppPageState extends State<MyMainAppPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Home Page')),
    Center(child: Text('History')),
    Center(child: Text('Menu')),
    Center(child: Text('Profile')),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    print("Tab changed to index: $index");
    // Place your onChange logic here
  }

  void _onFabPressed() {
    // Example action for FAB tap
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('FAB Pressed'),
            content: const Text('You pressed the floating action button!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        child: Icon(Icons.restaurant_menu),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            100,
          ), // large radius = circle/pill
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xff0d6efd),
        selectedItemColor: Colors.white, // Active icon/text color
        unselectedItemColor: Colors.blueAccent,
        currentIndex: _currentIndex,
        onTap: _onTabTapped, // handle tab change
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_outlined),
            label: 'Menu',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
