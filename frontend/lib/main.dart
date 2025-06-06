import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/main_app_page.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load(); // Load .env before runApp
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage());
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTitle = dotenv.env['APP_TITLE'] ?? '';
    return Scaffold(
      backgroundColor: const Color(0xff0d6efd),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 130),
            child: Lottie.asset('assets/Animation.json'),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    appTitle,
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                Center(
                  child: Text(
                    'Version 1.0',
                    style: TextStyle(fontSize: 13.5, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DisconnectScreen extends StatelessWidget {
  const DisconnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d6efd),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 130),
            child: Lottie.asset('assets/Disconnect.json'),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Sorry, An Http error has occurred. Please close the application client and try again.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool logged = false;
  bool loading = true;
  bool disconnect = false;

  void fetchData() async {
    try {
      final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
      final response = await http.get(Uri.parse('$appBackendUrl/api/ping'));
      Future.delayed(Duration(seconds: 2), () async {
        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          setState(() {
            loading = false;
            disconnect = false;
            logged = prefs.getString('token') != null;
          });
        } else {
          setState(() {
            disconnect = true;
            loading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        disconnect = true;
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SplashScreen();
    } else {
      if (disconnect) {
        return DisconnectScreen();
      } else {
        return logged ? MainAppPage() : LoginPage();
      }
    }
  }
}
