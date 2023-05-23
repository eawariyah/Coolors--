import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'editprofile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogoutPage extends StatelessWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logout"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Logout"),
          onPressed: () async {
            // Get the current user ID from the backend
            final response = await http.get(Uri.parse(
                'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/users_data/current_user_id'));
            final currentUserId = jsonDecode(response.body)['user_id'] ?? '';

            // Navigate to the EditProfilePage and pass the current user ID as an argument
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => EditProfilePage(currentUserId)),
            // );
          },
        ),
      ),
    );
  }
}
