import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  void loadData() {
    print('home page loaded');
  }

  @override
  Widget build(BuildContext context) {
    return Text("This is home page");
  }
}
