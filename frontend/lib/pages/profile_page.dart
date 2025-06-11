/// This file is part of the Sandy Andryanto Resto Application.
///
/// Author:     Sandy Andryanto <sandy.andryanto.blade@gmail.com>
/// Copyright:  2025
///
/// For full copyright and license information,
/// please view the LICENSE.md file distributed with this source code.
///
import 'package:flutter/material.dart';
import 'package:frontend/pages/change_password_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:frontend/widgets/alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  MyProfilePageState createState() => MyProfilePageState();
}

class MyProfilePageState extends State<MyProfilePage> {
  String? _selectedGender;
  String _errorMessage = "";
  String _successMessage = "";
  bool _loadingSubmit = false;
  bool _loadingUser = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void loadData() async {
    try {
      setState(() {
        _loadingUser = true;
      });
      final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$appBackendUrl/api/profile/detail'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      Future.delayed(Duration(seconds: 1), () {
        final body = jsonDecode(response.body);
        _emailController.text = body['email'].toString();
        _nameController.text = body['name'].toString();
        _addressController.text = body['address'].toString();
        _phoneController.text = body['phone'].toString();
        setState(() {
          _loadingUser = false;
          _selectedGender = body['gender'].toString();
        });
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      gotToLogin();
    }
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
        final response = await http.post(
          Uri.parse('$appBackendUrl/api/profile/update'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'email': _emailController.text,
            'name': _nameController.text,
            'gender': _selectedGender,
            'phone': _phoneController.text,
            'address': _addressController.text,
          }),
        );
        if (response.statusCode == 200) {
          Future.delayed(Duration(seconds: 1), () async {
            final body = jsonDecode(response.body);
            final message = body['message'].toString();
            setState(() {
              _loadingSubmit = false;
              _successMessage = message;
            });
            loadData();
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

  void onLogOut() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Do you want to confirm this action?'),
        action: SnackBarAction(
          label: 'Yes',
          onPressed: () {
            Future.delayed(Duration(seconds: 1), () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              gotToLogin();
            });
          },
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void onChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyChangePasswordPage()),
    );
  }

  void gotToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return Scaffold(
        backgroundColor: const Color(0xfff8f9fa),
        body: Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xff0d6efd),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color(0xfff8f9fa),
        body: Container(
          margin: EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Center(
                  child: Text(
                    "Please fill in the fields below to update current profile.",
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
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
                        enabled: !_loadingSubmit,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-Mail Address',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$',
                          ).hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: TextFormField(
                        enabled: !_loadingSubmit,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Please Enter Your Phone',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone is required';
                          }
                          if (value.length < 5) {
                            return 'Phone must be at least 5 digits';
                          }
                          if (value.length > 15) {
                            return 'Phone must be at most 15 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: TextFormField(
                        enabled: !_loadingSubmit,
                        keyboardType: TextInputType.name,
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Please Enter Your Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          if (value.length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          enabled: !_loadingSubmit,
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: "male", child: Text("Male")),
                          DropdownMenuItem(
                            value: "female",
                            child: Text("Female"),
                          ),
                        ],
                        onChanged:
                            (value) => setState(() => _selectedGender = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gender is required';
                          }
                          return null;
                        },
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: TextFormField(
                        enabled: !_loadingSubmit,
                        controller: _addressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                    ),
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
                                onPressed: () {
                                  onSubmit();
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
                                      ' Update Current Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          onChangePassword();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 8),
                            Text(
                              'Change Password',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          onLogOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 8),
                            Text(
                              'Log Out Application',
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
}
