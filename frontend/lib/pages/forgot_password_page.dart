import 'package:flutter/material.dart';
import 'package:frontend/widgets/alert.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/reset_password_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyForgotPasswordPage());
  }
}

class MyForgotPasswordPage extends StatefulWidget {
  const MyForgotPasswordPage({super.key});

  @override
  _MyForgotPasswordPageState createState() => _MyForgotPasswordPageState();
}

class _MyForgotPasswordPageState extends State<MyForgotPasswordPage> {
  String _errorMessage = "";
  String _successMessage = "";
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void gotToResetPassword(String token) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordPage(token: token)),
    );
  }

  void onSubmit() async {
    try {
      final email = _emailController.text;
      if (_formKey.currentState!.validate()) {
        setState(() {
          _loading = true;
          _successMessage = "";
          _errorMessage = "";
        });
        final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
        final response = await http.post(
          Uri.parse('$appBackendUrl/api/auth/email/forgot'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );
        if (response.statusCode == 200) {
          Future.delayed(Duration(seconds: 2), () async {
            final body = jsonDecode(response.body);
            final token = body['token'].toString();
            final message = body['message'].toString();
            setState(() {
              _loading = false;
              _successMessage = message;
            });
            gotToResetPassword(token);
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
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: Container(
        margin: EdgeInsets.only(top: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Forgot Password',
                style: TextStyle(fontSize: 23, color: Colors.black),
              ),
            ),
            Center(
              child: Text(
                "Please sign in with your e-mail address and correct password.",
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
            if (_errorMessage != "")
              Container(
                margin: EdgeInsets.only(top: 30),
                padding: EdgeInsets.only(left: 30, right: 30),
                child: MyAlert(
                  message: _errorMessage,
                  color: Colors.redAccent,
                  icon: Icons.close,
                ),
              ),
            if (_successMessage != "")
              Container(
                margin: EdgeInsets.only(top: 30),
                padding: EdgeInsets.only(left: 30, right: 30),
                child: MyAlert(
                  message: _successMessage,
                  color: Colors.green,
                  icon: Icons.send,
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
                                    'Request Password Reset',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
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
                            ' Back To Sign In',
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
