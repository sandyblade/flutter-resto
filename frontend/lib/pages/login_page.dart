/// This file is part of the Sandy Andryanto Resto Application.
///
/// Author:     Sandy Andryanto <sandy.andryanto.blade@gmail.com>
/// Copyright:  2025
///
/// For full copyright and license information,
/// please view the LICENSE.md file distributed with this source code.
///
import 'package:flutter/material.dart';
import 'package:frontend/pages/forgot_password_page.dart';
import 'package:frontend/pages/main_app_page.dart';
import 'package:frontend/widgets/alert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyLoginPage());
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  String _errorMessage = "";
  bool _loading = false;
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void gotToMainPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainAppPage(tabIndex: 0)),
    );
  }

  void onSubmit() async {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      if (_formKey.currentState!.validate()) {
        setState(() {
          _loading = true;
          _errorMessage = "";
        });
        final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
        final response = await http.post(
          Uri.parse('$appBackendUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );
        if (response.statusCode == 200) {
          Future.delayed(Duration(seconds: 2), () async {
            final body = jsonDecode(response.body);
            final token = body['token'].toString();
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
            setState(() {
              _loading = false;
            });
            gotToMainPage();
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: Container(
        margin: EdgeInsets.only(top: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Login to your account',
                style: TextStyle(fontSize: 23, color: Colors.black),
              ),
            ),
            Center(
              child: Text(
                ' Please sign in with your e-mail address and correct password.',
                style: TextStyle(fontSize: 13, color: Colors.black),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Center(
                child: Image.network(
                  'https://5an9y4lf0n50.github.io/demo-images/demo-resto/burger.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.only(left: 30, right: 30),
              child:
                  _errorMessage == ""
                      ? SizedBox()
                      : MyAlert(
                        message: _errorMessage,
                        color: Colors.redAccent,
                        icon: Icons.close,
                      ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      enabled: !_loading,
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
                      enabled: !_loading,
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Please Enter Your Password',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 characters';
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
                                    'Sign In Now',
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
            Container(
              width: double.infinity,
              height: 50,
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.only(left: 30, right: 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
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
                      'Forgot Password ?',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
