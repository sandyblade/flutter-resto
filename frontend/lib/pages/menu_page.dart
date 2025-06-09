import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/widgets/rating_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyMenuPage extends StatefulWidget {
  const MyMenuPage({super.key});

  @override
  MyMenuPageState createState() => MyMenuPageState();
}

class MyMenuPageState extends State<MyMenuPage> {
  String category = "all";
  int maxRating = 0;
  bool loading = true;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> originals = [];
  TextEditingController _searchController = TextEditingController();

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
      });
      final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$appBackendUrl/api/menu/list'),
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
          items = itemsCast;
          originals = itemsCast;
          maxRating = int.parse(itemsCast[0]['rating'].toString());
        });
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      gotToLogin();
    }
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
                    menu['category'],
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
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

  void handleFilter(String value) {
    if (value == 'all') {
      setState(() {
        category = value;
        items = originals;
      });
    } else {
      setState(() {
        items = originals;
      });
      List<Map<String, dynamic>> filteredItems =
          originals.where((item) {
            return item['category'] == value;
          }).toList();
      setState(() {
        category = value;
        items = filteredItems;
      });
    }
  }

  void handleSearch(String value) {
    if (value == '') {
      setState(() {
        items = originals;
      });
    } else {
      List<Map<String, dynamic>> filteredItems =
          originals.where((item) {
            return item['name'].toLowerCase().contains(value.toLowerCase()) ||
                item['category'].toLowerCase().contains(value.toLowerCase());
          }).toList();
      setState(() {
        items = filteredItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (value) {
                    handleSearch(value);
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Wrap(
                spacing: 3,
                children: [
                  ActionChip(
                    avatar: Icon(
                      Icons.lunch_dining,
                      size: 16,
                      color: Colors.white70,
                    ),
                    backgroundColor:
                        category != 'Appetizer'
                            ? Colors.green
                            : Colors.blueGrey,
                    label: Text(
                      'Appetizer',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: () {
                      handleFilter('Appetizer');
                    },
                  ),
                  ActionChip(
                    avatar: Icon(
                      Icons.ramen_dining,
                      size: 16,
                      color: Colors.white70,
                    ),
                    backgroundColor:
                        category != 'Main Course'
                            ? Colors.red
                            : Colors.blueGrey,
                    label: Text(
                      'Main Course',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: () {
                      handleFilter('Main Course');
                    },
                  ),
                  ActionChip(
                    avatar: Icon(Icons.cake, size: 16, color: Colors.white70),
                    backgroundColor:
                        category != 'Dessert'
                            ? Colors.deepOrange
                            : Colors.blueGrey,
                    label: Text(
                      'Dessert',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: () {
                      handleFilter('Dessert');
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Wrap(
                spacing: 2,
                children: [
                  ActionChip(
                    avatar: Icon(Icons.dining, size: 16, color: Colors.white70),
                    backgroundColor:
                        category != 'all' ? Colors.blue : Colors.blueGrey,
                    label: Text(
                      'All Menu',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: () {
                      handleFilter('all');
                    },
                  ),
                ],
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
      ),
    );
  }
}
