import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _emailController = TextEditingController();
  final _majorController = TextEditingController();
  final _passwordController = TextEditingController();

  final _studentIdNumberController = TextEditingController();
  final _dOBController = TextEditingController();
  final _yearGroupController = TextEditingController();
  final _campusResidenceController = TextEditingController();
  final _bestFoodController = TextEditingController();
  final _bestMovieController = TextEditingController();

  Future<void> _submitForm() async {
    final url =
        'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/users_data';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'studentIdNumber': _studentIdNumberController.text,
        'dOB': _dOBController.text,
        'yearGroup': _yearGroupController.text,
        'campusResidence': _campusResidenceController.text,
        'bestFood': _bestFoodController.text,
        'bestMovie': _bestMovieController.text,
        'email': _emailController.text,
        'Major': _majorController.text,
        'password': _passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      // Registration successful, display success message and navigate to login page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful.'),
        ),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // Registration failed, display error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Account'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _studentIdNumberController,
                    decoration:
                        InputDecoration(labelText: 'My student id number is:'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'My student id number is:';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'My name is:'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'My name is:';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration:
                        InputDecoration(labelText: 'My Ashesi email is:'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'My Ashesi email is:';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dOBController,
                    decoration: InputDecoration(labelText: 'I was born on:'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'I was born on:';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _yearGroupController,
                    decoration: InputDecoration(labelText: 'I am in class of:'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'I am in class of:';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _majorController,
                    decoration: InputDecoration(labelText: 'I major in:'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'I major in:';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _campusResidenceController,
                    decoration: InputDecoration(
                        labelText: 'I have campus residence? [yes/no]'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'I have campus residence? [yes/no] ';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bestFoodController,
                    decoration: InputDecoration(labelText: 'My best food is?'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'My best food is?';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bestMovieController,
                    decoration: InputDecoration(labelText: 'My best movie is?'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'My best movie is?';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelText: 'Please enter your new password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your new password.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitForm();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      }
                    },
                    child: Text('Create account'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
