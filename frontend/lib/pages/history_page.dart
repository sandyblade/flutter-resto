import 'package:flutter/material.dart';

class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  MyHistoryPageState createState() => MyHistoryPageState();
}

class MyHistoryPageState extends State<MyHistoryPage> {
  void loadData() {
    print('history page loaded');
  }

  @override
  Widget build(BuildContext context) {
    return Text("This is history page");
  }
}
