import 'package:flutter/material.dart';
import 'package:frontend/pages/main_app_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/widgets/rating_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyOrderPage());
  }
}

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});

  @override
  _MyOrderPageState createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  String category = "all";
  int currentIndex = 0;
  int maxRating = 0;
  double totalPaid = 0;
  bool loading = true;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> originals = [];
  List<Map<String, dynamic>> orders = [];
  TextEditingController _searchController = TextEditingController();

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

  void handleAdd(Map<String, dynamic> menu) {
    double sum = 0;
    for (var order in orders) {
      if (order['_id'] == menu['_id']) {
        final int qty = int.parse(menu["qty"].toString()) + 1;
        final double price = double.parse(
          menu['price']['\$numberDecimal'].toString(),
        );
        final double total = qty * price;
        order["qty"] = qty;
        order["total"] = total;
      }
      sum = sum + double.parse(order["total"].toString());
    }
    setState(() {
      orders = orders;
      totalPaid = sum;
    });
  }

  void handleLess(Map<String, dynamic> menu) {
    if (int.parse(menu["qty"].toString()) > 1) {
      double sum = 0;
      for (var order in orders) {
        if (order['_id'] == menu['_id']) {
          final int qty = int.parse(menu["qty"].toString()) - 1;
          final double price = double.parse(
            menu['price']['\$numberDecimal'].toString(),
          );
          final double total = qty * price;
          order["qty"] = qty;
          order["total"] = total;
        }
        sum = sum + double.parse(order["total"].toString());
      }
      setState(() {
        orders = orders;
        totalPaid = sum;
      });
    }
  }

  void handleRemove(Map<String, dynamic> menu) {
    orders.removeWhere((order) => order['_id'] == menu['_id']);
    double sum = 0;
    for (var order in orders) {
      if (order['_id'] == menu['_id']) {
        final int qty = int.parse(menu["qty"].toString());
        final double price = double.parse(
          menu['price']['\$numberDecimal'].toString(),
        );
        final double total = qty * price;
        order["qty"] = qty;
        order["total"] = total;
      }
      sum = sum + double.parse(order["total"].toString());
    }
    setState(() {
      orders = orders;
      totalPaid = sum;
    });
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
      child: InkWell(
        onTap: () {
          if (orders.isEmpty) {
            List<Map<String, dynamic>> newOrder = [];
            menu['qty'] = 1;
            menu['total'] = double.parse(
              menu['price']['\$numberDecimal'].toString(),
            );
            newOrder.add(menu);
            setState(() {
              orders = newOrder;
              totalPaid = double.parse(
                menu['price']['\$numberDecimal'].toString(),
              );
            });
          } else {
            List<Map<String, dynamic>> filter =
                orders.where((item) {
                  return item['_id'] == menu['_id'];
                }).toList();

            if (filter.isEmpty) {
              List<Map<String, dynamic>> newOrder = [];
              menu['qty'] = 1;
              menu['total'] = double.parse(
                menu['price']['\$numberDecimal'].toString(),
              );
              newOrder.add(menu);
              setState(() {
                orders = [...orders, ...newOrder];
                totalPaid =
                    totalPaid +
                    double.parse(menu['price']['\$numberDecimal'].toString());
              });
            } else {
              double sum = 0;
              for (var order in orders) {
                if (order['_id'] == menu['_id']) {
                  final int qty = int.parse(menu["qty"].toString());
                  final double price = double.parse(
                    menu['price']['\$numberDecimal'].toString(),
                  );
                  final double total = qty * price;
                  sum = sum + total;
                  menu["qty"] = qty;
                  menu["total"] = total;
                }
              }
              setState(() {
                orders = orders;
                totalPaid = sum;
              });
            }
          }
        },
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
                    border: Border.all(
                      color: const Color(0xfff8f9fa),
                      width: 1,
                    ),
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
      ),
    );
  }

  Widget _buildCardOrder(Map<String, dynamic> menu) {
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
                    "\$${menu['price']['\$numberDecimal']} x ${menu['qty'].toString()}",
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
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Wrap(
                      spacing: 3,
                      children: [
                        ActionChip(
                          avatar: Icon(
                            Icons.remove,
                            size: 16,
                            color: Colors.white70,
                          ),
                          backgroundColor: Colors.amber,
                          label: Text(
                            'Less',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          onPressed: () {
                            handleLess(menu);
                          },
                        ),
                        ActionChip(
                          avatar: Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white70,
                          ),
                          backgroundColor: Colors.green,
                          label: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          onPressed: () {
                            handleAdd(menu);
                          },
                        ),
                        ActionChip(
                          avatar: Icon(
                            Icons.delete_forever,
                            size: 16,
                            color: Colors.white70,
                          ),
                          backgroundColor: Colors.red,
                          label: Text(
                            'Remove',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          onPressed: () {
                            handleRemove(menu);
                          },
                        ),
                      ],
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

  Widget tabProduct() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
                      category != 'Appetizer' ? Colors.green : Colors.blueGrey,
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
                      category != 'Main Course' ? Colors.red : Colors.blueGrey,
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
    );
  }

  Widget tabCalculate() {
    final totalPaidText = loading ? '0' : totalPaid.toStringAsFixed(2);
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              child: Column(
                children:
                    orders.asMap().entries.map((entry) {
                      Map<String, dynamic> item = entry.value;
                      return _buildCardOrder(item);
                    }).toList(),
              ),
            ),
            Center(
              child: Text(
                orders.isEmpty ? 'No Orders' : 'TOTAL PAID \$ $totalPaidText',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.deepPurple, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabCheckout() {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget contentBody = Text('');
    if (currentIndex == 0) {
      contentBody = tabProduct();
    } else if (currentIndex == 1) {
      contentBody = tabCalculate();
    } else if (currentIndex == 2) {
      contentBody = tabCheckout();
    }
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: contentBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'fab1',
            onPressed:
                () => {
                  setState(() {
                    currentIndex = 0;
                  }),
                },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: currentIndex == 0 ? Colors.grey : Colors.amber,
            foregroundColor: Colors.white,
            child: Icon(Icons.fastfood),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'fab2',
            onPressed:
                () => {
                  setState(() {
                    currentIndex = 1;
                  }),
                },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: currentIndex == 1 ? Colors.grey : Colors.purple,
            foregroundColor: Colors.white,
            child: Icon(Icons.shopping_bag),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'fab3',
            onPressed:
                () => {
                  setState(() {
                    currentIndex = 2;
                  }),
                },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: currentIndex == 2 ? Colors.grey : Colors.green,
            foregroundColor: Colors.white,
            child: Icon(Icons.price_check),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'fab4',
            onPressed:
                () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainAppPage(tabIndex: 0),
                    ),
                  ),
                },
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(Icons.close),
          ),
        ],
      ),
    );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }
}
