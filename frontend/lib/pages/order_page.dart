/// This file is part of the Sandy Andryanto Resto Application.
///
/// Author:     Sandy Andryanto <sandy.andryanto.blade@gmail.com>
/// Copyright:  2025
///
/// For full copyright and license information,
/// please view the LICENSE.md file distributed with this source code.
///
import 'package:flutter/material.dart';
import 'package:frontend/pages/main_app_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/widgets/rating_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/widgets/alert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';

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
  String? _selectedTable;
  String? _selectedOrderType;
  String _errorMessage = "";
  String _successMessage = "";
  bool _loadingSubmit = false;
  String category = "all";
  int currentIndex = 0;
  int maxRating = 0;
  double totalPaid = 0;
  bool loading = true;
  List<Map<String, dynamic>> tables = [];
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> originals = [];
  List<Map<String, dynamic>> orders = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _orderNumberController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _totalPaidController = TextEditingController();

  int randomIntFromInterval(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  void goToMainApp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainAppPage(tabIndex: 0)),
    );
  }

  void onSubmit() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _loadingSubmit = true;
          _successMessage = "";
          _errorMessage = "";
        });
        final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final formBody = {
          'checkout': _selectedOrderType == 'Take Away',
          'order_number': _orderNumberController.text,
          'customer_name': _customerNameController.text,
          'order_type': _selectedOrderType,
          'status': _selectedOrderType == 'Take Away' ? 1 : 0,
          'cart': orders,
          'table_number': _selectedTable,
          'total_paid': double.parse(_totalPaidController.text.toString()),
        };

        final response = await http.post(
          Uri.parse('$appBackendUrl/api/order/save'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(formBody),
        );

        if (response.statusCode == 200) {
          Future.delayed(Duration(seconds: 1), () async {
            final body = jsonDecode(response.body);
            final message = body['message'].toString();
            setState(() {
              _loadingSubmit = false;
              _successMessage = message;
            });
            await Future.delayed(Duration(seconds: 2));
            goToMainApp();
          });
        } else {
          Future.delayed(Duration(seconds: 2), () {
            final body = jsonDecode(response.body);
            final errorMessage = body['error'].toString();
            setState(() {
              _loadingSubmit = false;
              _errorMessage = errorMessage;
            });
          });
        }
      }
    } catch (e) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _loadingSubmit = false;
          _errorMessage = e.toString();
        });
      });
      throw Exception(e);
    }
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
      final indexes = randomIntFromInterval(1, 1000);
      final orderNumberGenerate = indexes.toString().padLeft(5, '0');
      final dateIndex = DateFormat('yyyyMMdd').format(DateTime.now());
      final orderNumber = "$dateIndex$orderNumberGenerate";
      final customerName = "Customer $dateIndex";
      Future.delayed(Duration(seconds: 1), () {
        final body = jsonDecode(response.body);
        final itemsCast = body.cast<Map<String, dynamic>>();
        setState(() {
          loading = false;
          items = itemsCast;
          originals = itemsCast;
          maxRating = int.parse(itemsCast[0]['rating'].toString());
          _customerNameController.text = customerName;
          _orderNumberController.text = orderNumber;
          _totalPaidController.text = "0.0";
        });
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      gotToLogin();
    }
  }

  void loadTable() async {
    try {
      final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$appBackendUrl/api/home/table'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      Future.delayed(Duration(seconds: 1), () {
        final body = jsonDecode(response.body);
        final tableCast = body.cast<Map<String, dynamic>>();
        setState(() {
          tables = tableCast;
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
      _totalPaidController.text = totalPaid.toStringAsFixed(2);
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
        _totalPaidController.text = totalPaid.toStringAsFixed(2);
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
      _totalPaidController.text = totalPaid.toStringAsFixed(2);
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
              _totalPaidController.text = totalPaid.toStringAsFixed(2);
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
                _totalPaidController.text = totalPaid.toStringAsFixed(2);
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
                _totalPaidController.text = totalPaid.toStringAsFixed(2);
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
    final totalText = double.parse(menu['total'].toString()).toStringAsFixed(2);
    final priceText = double.parse(
      menu['price']['\$numberDecimal'].toString(),
    ).toStringAsFixed(2);
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
                    "\$$priceText x ${menu['qty'].toString()}",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "\$$totalText",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.deepOrange,
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
    if (orders.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xfff8f9fa),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 0),
                child: Center(
                  child: Text(
                    "No Orders",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color(0xfff8f9fa),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Center(
                  child: Text(
                    "Please fill in the fields below to create order.",
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ),
              if (_errorMessage != "")
                Container(
                  margin: EdgeInsets.only(bottom: 1),
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: MyAlert(
                    message: _errorMessage,
                    color: Colors.redAccent,
                    icon: Icons.close,
                  ),
                ),
              if (_successMessage != "")
                Container(
                  margin: EdgeInsets.only(bottom: 1),
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: MyAlert(
                    message: _successMessage,
                    color: Colors.green,
                    icon: Icons.check,
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: TextFormField(
                        readOnly: true,
                        enabled: !_loadingSubmit,
                        keyboardType: TextInputType.name,
                        controller: _orderNumberController,
                        decoration: InputDecoration(
                          labelText: 'Order Number',
                          prefixIcon: Icon(Icons.check_box),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: TextFormField(
                        enabled: !_loadingSubmit,
                        keyboardType: TextInputType.name,
                        controller: _customerNameController,
                        decoration: InputDecoration(
                          labelText: 'Customer Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Customer Name is required';
                          }
                          if (value.length < 3) {
                            return 'Customer Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: DropdownButtonFormField<String>(
                        value: _selectedOrderType,
                        decoration: InputDecoration(
                          enabled: !_loadingSubmit,
                          labelText: 'Order Type',
                          prefixIcon: Icon(Icons.local_cafe),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: "Dine In",
                            child: Text("Dine In"),
                          ),
                          DropdownMenuItem(
                            value: "Take Away",
                            child: Text("Take Away"),
                          ),
                        ],
                        onChanged:
                            (value) =>
                                setState(() => _selectedOrderType = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Order Typ is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_selectedOrderType == 'Dine In')
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: DropdownButtonFormField<dynamic>(
                          decoration: InputDecoration(
                            enabled: !_loadingSubmit,
                            labelText: 'Table Number',
                            prefixIcon: Icon(Icons.restaurant),
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedTable,
                          onChanged: (value) {
                            setState(() {
                              _selectedTable = value;
                            });
                          },
                          items:
                              tables.map<DropdownMenuItem<dynamic>>((item) {
                                return DropdownMenuItem<dynamic>(
                                  value: item['name'],
                                  child: Text(item['name']),
                                );
                              }).toList(),
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: TextFormField(
                        readOnly: true,
                        enabled: !_loadingSubmit,
                        keyboardType: TextInputType.name,
                        controller: _totalPaidController,
                        decoration: InputDecoration(
                          labelText: 'Total Paid',
                          prefixIcon: Icon(Icons.payments),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (_selectedOrderType == 'Dine In' ||
                        _selectedOrderType == 'Take Away')
                      Container(
                        width: double.infinity,
                        height: 50,
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child:
                            _loadingSubmit
                                ? Shimmer.fromColors(
                                  baseColor: Colors.grey,
                                  highlightColor: Colors.white54,
                                  child: Container(
                                    width: 200,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                )
                                : ElevatedButton(
                                  onPressed: () async {
                                    final confirmed = await showConfirmDialog(
                                      context,
                                      "Are you sure you want to process this order ?",
                                    );
                                    if (confirmed == true) {
                                      onSubmit();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff0d6efd),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 8),
                                      Text(
                                        _selectedOrderType == 'Take Away'
                                            ? 'Checkout'
                                            : 'Save Order',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
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

  Future<bool?> showConfirmDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Order Confirmation'),
            content: Text(message),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: Text('Ok, Continue'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _customerNameController.dispose();
    _totalPaidController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
      loadTable();
    });
  }
}
