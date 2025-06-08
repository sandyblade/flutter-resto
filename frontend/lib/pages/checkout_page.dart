import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CheckoutPage());
  }
}

class MyCheckoutPage extends StatefulWidget {
  const MyCheckoutPage({super.key});

  @override
  _MyCheckoutPageState createState() => _MyCheckoutPageState();
}

class _MyCheckoutPageState extends State<MyCheckoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("CheckoutPage"));
  }
}
