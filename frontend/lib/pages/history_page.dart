import 'package:flutter/material.dart';
import 'package:frontend/pages/history_detail_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  MyHistoryPageState createState() => MyHistoryPageState();
}

class MyHistoryPageState extends State<MyHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  String search = "";
  int limit = 10;
  int page = 1;
  bool loading = true;
  bool hasMore = true;
  bool isSearching = false;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    loadData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !loading &&
          hasMore) {
        loadData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void gotToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void loadData() async {
    try {
      setState(() {
        loading = true;
        page = page > 1 ? page + 1 : 1;
      });
      await Future.delayed(const Duration(seconds: 2));
      final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(
          '$appBackendUrl/api/history/list?page=${page.toString()}&limit=${limit.toString()}&search=${search.toString()}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      Future.delayed(Duration(seconds: 1), () {
        final body = jsonDecode(response.body);
        final itemsCast = body.cast<Map<String, dynamic>>();
        setState(() {
          loading = false;
          items = [...items, ...itemsCast];
          hasMore = itemsCast.length == 0;
        });
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      gotToLogin();
    }
  }

  void gotToDetail(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryDetailPage(historyId: id)),
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

  Widget _buildCard(Map<String, dynamic> item) {
    return Card(
      color: const Color(0xffF8F8FF),
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableRowWidget(
              label: 'Order ID',
              value: item["order_number"].toString(),
              space: 65,
            ),
            TableRowWidget(
              label: 'Order Type',
              value: item["order_type"].toString(),
              space: 48,
            ),
            TableRowWidget(
              label: 'Order Date',
              value: item["created_at"].toString(),
              space: 48,
            ),
            TableRowWidget(
              label: 'Customer Name',
              value: item["customer_name"].toString(),
              space: 10,
            ),
            TableRowWidget(
              label: 'Casheir Name',
              value: item["cashier_name"].toString(),
              space: 23,
            ),
            if (item["order_type"].toString() == 'Dine In')
              TableRowWidget(
                label: 'Table Number',
                value: item["table_number"].toString(),
                space: 23,
              ),
            TableRowWidget(
              label: 'Total Item',
              value: item["total_item"].toString(),
              space: 48,
            ),
            TableRowWidget(
              label: 'Total Paid',
              value: item["total_paid"].toString(),
              space: 48,
            ),
            Container(
              width: double.infinity,
              height: 50,
              margin: EdgeInsets.only(top: 25),
              child: ElevatedButton.icon(
                onPressed: () {
                  gotToDetail(item['_id']);
                },
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                icon: const Icon(Icons.search),
                label: const Text(
                  'View Detail',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(int index) {
    if (index == items.length) {
      return hasMore
          ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          )
          : const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No more items')),
          );
    }
    return SingleChildScrollView(
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title:
            isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                    loadData();
                  },
                )
                : const Text('Search...'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  _searchController.clear();
                  search = '';
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: page,
        itemBuilder: (context, index) => buildItem(index),
      ),
    );
  }
}

class TableRowWidget extends StatelessWidget {
  final double space;
  final String label;
  final String value;

  const TableRowWidget({
    super.key,
    required this.label,
    required this.value,
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          SizedBox(width: space),
          Text(':'),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: Text(value)),
          ),
        ],
      ),
    );
  }
}
