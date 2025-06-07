import 'package:flutter/material.dart';
import 'package:frontend/widgets/alert.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordPage extends StatelessWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyResetPasswordPage(token: token));
  }
}

class MyResetPasswordPage extends StatefulWidget {
  final String token;

  const MyResetPasswordPage({Key? key, required this.token}) : super(key: key);

  @override
  _MyResetPasswordPageState createState() => _MyResetPasswordPageState();
}

class _MyResetPasswordPageState extends State<MyResetPasswordPage> {
  bool _obscure = true;
  bool _obscure_confirm = true;

  String _errorMessage = "";
  String _successMessage = "";
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  void gotToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void onSubmit() async {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      final passwordConfirm = _passwordConfirmController.text;
      if (_formKey.currentState!.validate()) {
        setState(() {
          _loading = true;
          _successMessage = "";
          _errorMessage = "";
        });
        final token = widget.token;
        final appBackendUrl = dotenv.env['APP_BACKEND_URL'] ?? '';
        final response = await http.post(
          Uri.parse('$appBackendUrl/api/auth/email/reset/$token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
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
            gotToLogin();
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
  void dispose() {
    _passwordController.dispose();
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
        margin: EdgeInsets.only(top: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Reset Password',
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
                                    'Reset Password',
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
