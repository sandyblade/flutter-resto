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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Hello World', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
