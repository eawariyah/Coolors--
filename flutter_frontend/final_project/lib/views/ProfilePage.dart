import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String email;
  const ProfilePage({Key? key, required this.email}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};

  Future<void> _fetchUserData() async {
    final response = await http.get(Uri.parse(
        'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/users_data?email=${widget.email}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      int emailIndex = -1;
      for (int i = 0; i < data.length; i++) {
        if (data[i]['email'] == widget.email) {
          emailIndex = i;
          break;
        }
      }
      if (emailIndex >= 0) {
        setState(() {
          userData = data[emailIndex];
        });
      } else {
        throw Exception('User not found');
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile'),
      ),
      body: userData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Name: ${userData['name']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Email: ${userData['email']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Student ID Number: ${userData['studentIdNumber']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Year Group: ${userData['yearGroup']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Major: ${userData['Major']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Campus Residence: ${userData['campusResidence']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Date of Birth: ${userData['dOB']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Best Movie: ${userData['bestMovie']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Best Food: ${userData['bestFood']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
    );
  }
}
