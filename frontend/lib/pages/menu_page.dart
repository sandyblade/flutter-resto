import 'package:flutter/material.dart';

class MyMenuPage extends StatefulWidget {
  const MyMenuPage({super.key});

  @override
  MyMenuPageState createState() => MyMenuPageState();
}

class MyMenuPageState extends State<MyMenuPage> {
  void loadData() {
    print('menu page loaded');
  }

  @override
  Widget build(BuildContext context) {
    return Text("This is menu page");
  }
}
