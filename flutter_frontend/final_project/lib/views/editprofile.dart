import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import the http package
import 'package:http/http.dart' as http;

// Define the URL for the Flask endpoint
final String url =
    'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/users_data';

// Define the user ID from the route parameter
String userId = 'your_user_id';

// Fetch the user data
Future<Map<String, dynamic>> fetchUserData() async {
  final response = await http.get(Uri.parse('$url/$userId'));
  return json.decode(response.body);
}

// Submit the form data
Future<http.Response> submitForm(Map<String, dynamic> formData) async {
  final response = await http.put(Uri.parse('$url/$userId'), body: formData);
  return response;
}

class EditProfilePage extends StatefulWidget {
  final String email;
  final String userId;
  const EditProfilePage({Key? key, required this.email, required this.userId})
      : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // final _nameController = TextEditingController();
  final _majorController = TextEditingController();
  final _dOBController = TextEditingController();
  final _yearGroupController = TextEditingController();
  final _campusResidenceController = TextEditingController();
  final _bestFoodController = TextEditingController();
  final _bestMovieController = TextEditingController();

  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await http.get(
      Uri.parse(
          'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/users_data/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        userData = data[0];
        // _nameController.text = userData['name'] ?? '';
        _majorController.text = userData['Major'] ?? '';
        _dOBController.text = userData['dOB'] ?? '';
        _yearGroupController.text = userData['yearGroup'] ?? '';
        _campusResidenceController.text = userData['campusResidence'] ?? '';
        _bestFoodController.text = userData['bestFood'] ?? '';
        _bestMovieController.text = userData['bestMovie'] ?? '';
      });
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> _submitForm() async {
    final url =
        'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/users_data/${widget.userId}';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        // 'name': _nameController.text,
        'Major': _majorController.text,
        'dOB': _dOBController.text,
        'yearGroup': _yearGroupController.text,
        'campusResidence': _campusResidenceController.text,
        'bestFood': _bestFoodController.text,
        'bestMovie': _bestMovieController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                // TextFormField(
                //   // controller: _nameController,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     labelText: 'Name',
                //   ),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter your name';
                //     }
                //     return null;
                //   },
                // ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _majorController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Major',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your major';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _dOBController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Date of Birth',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _yearGroupController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Year Group',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your year group';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _campusResidenceController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Campus Residence',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your campus residence';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _bestFoodController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Best Food',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your best food';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _bestMovieController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Best Movie',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your best movie';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitForm();
                      }
                    },
                    child: Text('Update Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
