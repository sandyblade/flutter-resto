import 'package:flutter/material.dart';
import 'package:frontend/pages/main_app_page.dart';
import 'package:frontend/widgets/alert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyChangePasswordPage extends StatefulWidget {
  const MyChangePasswordPage({super.key});

  @override
  MyChangePasswordPageState createState() => MyChangePasswordPageState();
}

class MyChangePasswordPageState extends State<MyChangePasswordPage> {
  bool _obscure = true;
  bool _obscure_current = true;
  bool _obscure_confirm = true;

  String _errorMessage = "";
  String _successMessage = "";
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();
  final _passwordCurrentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  void onSubmit() async {
    try {
      final passwordCurrent = _passwordCurrentController.text;
      final password = _passwordController.text;
      final passwordConfirm = _passwordConfirmController.text;
      if (_formKey.currentState!.validate()) {
        setState(() {
          _loading = true;
          _successMessage = "";
          _errorMessage = "";
        });
        final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final response = await http.post(
          Uri.parse('$appBackendUrl/api/profile/password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'currentPassword': passwordCurrent,
            'password': password,
            'confirmPassword': passwordConfirm,
          }),
        );
        if (response.statusCode == 200) {
          Future.delayed(Duration(seconds: 2), () async {
            final body = jsonDecode(response.body);
            final message = body['message'].toString();
            setState(() {
              _loading = false;
              _successMessage = message;
            });
          });
        } else {
          Future.delayed(Duration(seconds: 2), () {
            final body = jsonDecode(response.body);
            final errorMessage = body['error'].toString();
            setState(() {
              _loading = false;
              _errorMessage = errorMessage;
            });
          });
        }
      }
    } catch (e) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _loading = false;
          _errorMessage = e.toString();
        });
      });
      throw Exception(e);
    }
  }

  void goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainAppPage(tabIndex: 3)),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordCurrentController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  "Please fill in the fields below to update current password.",
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
                      enabled: !_loading,
                      controller: _passwordCurrentController,
                      obscureText: _obscure_current,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure_current
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscure_current = !_obscure_current;
                            });
                          },
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter Current password'
                                  : null,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      enabled: !_loading,
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscure = !_obscure;
                            });
                          },
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter New password'
                                  : null,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      enabled: !_loading,
                      controller: _passwordConfirmController,
                      obscureText: _obscure_confirm,
                      decoration: InputDecoration(
                        labelText: 'New Password Confirmation',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure_confirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscure_confirm = !_obscure_confirm;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
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
                        _loading
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
                                    'Change Current Password',
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
                        goToProfile();
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
                            ' Back To Profile',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
