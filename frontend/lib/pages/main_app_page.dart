import 'package:flutter/material.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/history_page.dart';
import 'package:frontend/pages/menu_page.dart';
import 'package:frontend/pages/order_page.dart';
import 'package:frontend/pages/profile_page.dart';

class MainAppPage extends StatelessWidget {
  final int tabIndex;

  const MainAppPage({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyMainAppPage(tabIndex: tabIndex));
  }
}

class MyMainAppPage extends StatefulWidget {
  final int tabIndex;

  const MyMainAppPage({Key? key, required this.tabIndex}) : super(key: key);

  @override
  _MyMainAppPageState createState() => _MyMainAppPageState();
}

class _MyMainAppPageState extends State<MyMainAppPage> {
  int _currentIndex = 0;
  final GlobalKey<MyHomePageState> homeKey = GlobalKey<MyHomePageState>();
  final GlobalKey<MyHistoryPageState> historyKey =
      GlobalKey<MyHistoryPageState>();
  final GlobalKey<MyMenuPageState> menuKey = GlobalKey<MyMenuPageState>();
  final GlobalKey<MyProfilePageState> profileKey =
      GlobalKey<MyProfilePageState>();

  late final List<Widget> _pages;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      homeKey.currentState?.loadData();
    } else if (index == 1) {
      historyKey.currentState?.loadData();
    } else if (index == 2) {
      menuKey.currentState?.loadData();
    } else if (index == 3) {
      profileKey.currentState?.loadData();
    }
  }

  void _onFabPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentIndex = widget.tabIndex;
    });
    _pages = [
      MyHomePage(key: homeKey),
      MyHistoryPage(key: historyKey),
      MyMenuPage(key: menuKey),
      MyProfilePage(key: profileKey),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeKey.currentState?.loadData();
    });
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xff0d6efd),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.blueAccent,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
