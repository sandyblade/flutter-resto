import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/widgets/rating_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int totalDineIn = 0;
  int totalOrder = 0;
  int totalTakeAway = 0;
  int maxRating = 0;
  double totalSale = 0.0;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> tables = [];
  bool loading = true;
  bool checkout = false;

  void loadData() async {
    try {
      setState(() {
        loading = true;
      });
      final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$appBackendUrl/api/home/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      Future.delayed(Duration(seconds: 1), () {
        final body = jsonDecode(response.body);
        final totalSales = double.parse(body['total_sales'].toString());
        final productsCast = body['products'].cast<Map<String, dynamic>>();
        final tableCast = body['tables'].cast<Map<String, dynamic>>();
        setState(() {
          loading = false;
          totalDineIn = int.parse(body['total_dine_in'].toString());
          totalOrder = int.parse(body['total_orders'].toString());
          totalTakeAway = int.parse(body['total_take_away'].toString());
          totalSale = double.parse(totalSales.toStringAsFixed(2));
          products = productsCast;
          tables = tableCast;
          maxRating = int.parse(productsCast[0]['rating'].toString());
        });
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      gotToLogin();
    }
  }

  void gotToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget _buildRow(int offset) {
    int limit = 3;
    int end = (offset + limit > tables.length) ? tables.length : offset + limit;
    List<Widget> itemWidgets =
        tables.sublist(offset, end).map((item) {
          return Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(5.0),
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.shade400),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    item['name'],
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.network(
                    'https://5an9y4lf0n50.github.io/demo-images/demo-resto/table.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    int.parse(item['status'].toString()) == 1
                        ? 'Available'
                        : 'Reserved',
                    style: TextStyle(
                      color:
                          int.parse(item['status'].toString()) == 1
                              ? Colors.green
                              : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();

    return Row(children: itemWidgets);
  }

  Widget _buildRowShimmer() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Shimmer.fromColors(
            baseColor: Colors.grey,
            highlightColor: Colors.white54,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Shimmer.fromColors(
            baseColor: Colors.grey,
            highlightColor: Colors.white54,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Shimmer.fromColors(
            baseColor: Colors.grey,
            highlightColor: Colors.white54,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> menu) {
    return Card(
      color: const Color(0xffF8F8FF),
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xfff8f9fa), width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(menu['image'], fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu['name'],
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "\$" + menu['price']['\$numberDecimal'].toString(),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  MyRatingWidget(
                    maxRating: maxRating,
                    rating: int.parse(menu['rating'].toString()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Card(
      color: const Color(0xffF8F8FF),
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white54,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 9,
              child: Container(
                alignment: Alignment.center,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white54,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerLoader() {
    return Expanded(
      child: Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: const Color(0xffFFF5EE),
          child: Container(
            width: 70,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: const Color(0xffF8F8FF),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children:
                      loading
                          ? [
                            _shimmerLoader(),
                            _shimmerLoader(),
                            _shimmerLoader(),
                            _shimmerLoader(),
                          ]
                          : [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Icon(
                                      Icons.shop,
                                      size: 32,
                                      color: const Color(0xff198754),
                                    ),
                                  ),
                                  Text(
                                    'Revenue',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xff198754),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$$totalSale',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xff198754),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Icon(
                                      Icons.shopping_cart,
                                      size: 32,
                                      color: const Color(0xff0d6efd),
                                    ),
                                  ),
                                  Text(
                                    'Orders',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xff0d6efd),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$totalOrder Sales',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xff0d6efd),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Icon(
                                      Icons.coffee,
                                      size: 32,
                                      color: const Color(0xffdc3545),
                                    ),
                                  ),
                                  Text(
                                    'Dine In',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xffdc3545),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$totalDineIn Orders',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xffdc3545),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Icon(
                                      Icons.redeem,
                                      size: 32,
                                      color: const Color(0xff712cf9),
                                    ),
                                  ),
                                  Text(
                                    'Take Away',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xff712cf9),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$totalTakeAway Orders',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xff712cf9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                ),
              ),
            ),
            Card(
              color: const Color(0xffF8F8FF),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children:
                      loading
                          ? [
                            _buildRowShimmer(),
                            SizedBox(height: 5),
                            _buildRowShimmer(),
                            SizedBox(height: 5),
                            _buildRowShimmer(),
                            SizedBox(height: 5),
                            _buildRowShimmer(),
                          ]
                          : [
                            _buildRow(0),
                            SizedBox(height: 5),
                            _buildRow(3),
                            SizedBox(height: 5),
                            _buildRow(6),
                          ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children:
                    loading
                        ? [
                          _buildCardShimmer(),
                          _buildCardShimmer(),
                          _buildCardShimmer(),
                          _buildCardShimmer(),
                          _buildCardShimmer(),
                        ]
                        : products.asMap().entries.map((entry) {
                          Map<String, dynamic> item = entry.value;
                          return _buildCard(item);
                        }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
