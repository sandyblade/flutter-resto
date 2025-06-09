import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/history_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HistoryDetailPage extends StatelessWidget {
  final String historyId;

  const HistoryDetailPage({super.key, required this.historyId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHistoryDetailPage(historyId: historyId));
  }
}

class MyHistoryDetailPage extends StatefulWidget {
  final String historyId;

  const MyHistoryDetailPage({Key? key, required this.historyId})
    : super(key: key);

  @override
  _MyHistoryDetailPageState createState() => _MyHistoryDetailPageState();
}

class _MyHistoryDetailPageState extends State<MyHistoryDetailPage> {
  bool loading = true;
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic> order = {};

  void goToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHistoryPage()),
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

  Widget _buildCard(Map<String, dynamic> menu) {
    final priceText = menu['price']['\$numberDecimal'].toString();
    final qtyText = menu['qty'].toString();
    final totalText = menu['total']['\$numberDecimal'].toString();
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
                child: Image.network(menu['menu_image'], fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu['menu_name'],
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$ $priceText x $qtyText',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$ $totalText',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      setState(() {
        loading = true;
      });
      final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$appBackendUrl/api/history/detail/${widget.historyId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      Future.delayed(Duration(seconds: 1), () {
        final body = jsonDecode(response.body);
        final itemsCast = body["cart"].cast<Map<String, dynamic>>();
        final orderCast = body["order"].cast<String, dynamic>();
        setState(() {
          loading = false;
          items = itemsCast;
          order = orderCast;
        });
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPaidText = loading ? '0' : order['total_paid'].toString();
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                        : items.asMap().entries.map((entry) {
                          Map<String, dynamic> item = entry.value;
                          return _buildCard(item);
                        }).toList(),
              ),
            ),
            if (!loading)
              Center(
                child: Text(
                  'TOTAL PAID \$ $totalPaidText',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.deepPurple, fontSize: 20),
                ),
              ),
            Container(
              width: double.infinity,
              height: 50,
              margin: EdgeInsets.only(top: 15),
              child: ElevatedButton.icon(
                onPressed: () {
                  goToHistory();
                },
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.white,
                  backgroundColor: Colors.deepOrangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'Back To History',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
