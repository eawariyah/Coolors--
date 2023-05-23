import 'dart:math';
import 'package:flutter/material.dart';
import 'WelcomePage.dart';
import 'editprofile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ProfilePage.dart';

class Basics extends StatelessWidget {
  const Basics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = "Feed";
  Color selectedColor = Colors.white;

  Widget _buildFeedWidget() {
    return FutureBuilder(
      future: http.get(Uri.parse(
          'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/rgb_data')),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<dynamic> data = jsonDecode(snapshot.data!.body);
        Map<String, List<Map<String, dynamic>>> colorMap = {};

        for (var rgbData in data) {
          String userId = rgbData['user_id'];
          List<dynamic> batchData = rgbData['batch_data'];
          for (var rgb in batchData) {
            if (!colorMap.containsKey(userId)) {
              colorMap[userId] = [];
            }
            colorMap[userId]!.add({
              'r': rgb['r'],
              'g': rgb['g'],
              'b': rgb['b'],
              'text': rgb['text']
            });
          }
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              for (var userId in colorMap.keys)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        'Anonymous user',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var color in colorMap[userId]!)
                            Stack(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  height:
                                      MediaQuery.of(context).size.width * 0.2,
                                  color: Color.fromRGBO(
                                      color['r'], color['g'], color['b'], 1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'R: ${color['r']} G: ${color['g']} B: ${color['b']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        color['text'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  final emailController = TextEditingController();

  Widget _buildCreateWidget() {
    List<Map<String, dynamic>> rgbDataList = [];

    Color userInputColor(int red, int green, int blue) {
      return Color.fromRGBO(red, green, blue, 1);
    }

    List<TextEditingController> redControllers =
        List.generate(5, (_) => TextEditingController());
    List<TextEditingController> greenControllers =
        List.generate(5, (_) => TextEditingController());
    List<TextEditingController> blueControllers =
        List.generate(5, (_) => TextEditingController());
    List<TextEditingController> textControllers =
        List.generate(5, (_) => TextEditingController());

    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create your new RGB entry and add a text to describe it!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 24),
            for (int i = 0; i < 5; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Input $i',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: redControllers[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Red (0-255)',
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: greenControllers[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Green (0-255)',
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: blueControllers[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Blue (0-255)',
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: textControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Text',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ElevatedButton(
              onPressed: () async {
                for (int i = 0; i < 5; i++) {
                  int r = int.tryParse(redControllers[i].text) ?? 0;
                  int g = int.tryParse(greenControllers[i].text) ?? 0;
                  int b = int.tryParse(blueControllers[i].text) ?? 0;
                  String text = textControllers[i].text;
                  if (r != null && g != null && b != null && text.isNotEmpty) {
                    rgbDataList.add({
                      'r': r,
                      'g': g,
                      'b': b,
                      'text': text,
                    });
                  }
                }

                if (rgbDataList.length == 5) {
                  // Prompt the user to enter their email
                  final email = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      String inputText = '';
                      return AlertDialog(
                        title: const Text('Enter Your Email'),
                        content: TextField(
                          onChanged: (value) {
                            inputText = value;
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(inputText);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );

                  if (email != null) {
                    // Fetch the user ID using the email entered by the user
                    final response = await http.get(Uri.parse(
                        'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/users_data/current_user_id_from_email?email=$email'));

                    if (response.statusCode == 200) {
                      final userId = json.decode(response.body)['user_id'];
                      // Replace the fixed user ID in the URL with the current user ID
                      final postResponse = await http.post(
                        Uri.parse(
                            'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/users_data/$userId/rgb_data'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode(rgbDataList),
                      );

                      if (postResponse.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'New batch of RGB data added successfully, emails sent successfully! Check feed ➡️'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Failed to add new batch of RGB data'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to get current user ID'),
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid RGB data'),
                    ),
                  );
                }
              },
              child: Text('Add colors'),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Take a dive!"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.black),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Feed',
          ),
        ],
        onTap: (index) {
          setState(() {
            if (index == 0) {
              selectedTab = "Create";
            } else if (index == 1) {
              selectedTab = "Feed";
            }
          });
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                "Bio",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),

            ListTile(
              title: const Text("View Profile"),
              onTap: () async {
                Navigator.pop(context);
                final BuildContext dialogContext = context; // capture context
                final email = await showDialog<String>(
                  context: dialogContext, // use captured context
                  builder: (BuildContext context) {
                    String inputText = '';
                    return AlertDialog(
                      title: const Text('Enter Your Email'),
                      content: TextField(
                        onChanged: (value) {
                          inputText = value;
                        },
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(inputText);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => email != null
                        ? ProfilePage(email: email)
                        : const SizedBox.shrink(), // or some other fallback
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Edit Profile"),
              onTap: () async {
                Navigator.pop(context);
                final BuildContext dialogContext = context; // capture context
                final email = await showDialog<String>(
                  context: dialogContext, // use captured context
                  builder: (BuildContext context) {
                    String inputText = '';
                    return AlertDialog(
                      title: const Text('Enter Your Email'),
                      content: TextField(
                        onChanged: (value) {
                          inputText = value;
                        },
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(inputText);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
                // Fetch the user ID using the email entered by the user
                final response = await http.get(Uri.parse(
                    'https://us-central1-lab5-383223.cloudfunctions.net/coolorsplusplus/users_data/current_user_id_from_email?email=$email'));
                if (response.statusCode == 200) {
                  final userId = json.decode(response.body)['user_id'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfilePage(email: email!, userId: userId!),
                    ),
                  );
                } else {
                  // Handle error when user is not authenticated
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User not authenticated'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),

            // import 'ProfilePage.dart';

            ListTile(
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: selectedTab == "Feed" ? _buildFeedWidget() : _buildCreateWidget(),
    );
  }
}
