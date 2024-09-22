import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../home_screen.dart';
import '../offices/homePage.dart' as Offices;
import '../Employees/homePage.dart' as Employees;

class Item {
  Item({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.head,
    this.width = 90.0,
    this.height = 90.0,
  });

  final int id;
  final String imagePath;

  final String name;
  final String head;
  final double width;
  final double height;
}

class TeamsHomePage extends StatefulWidget {
  const TeamsHomePage({super.key});

  @override
  State<TeamsHomePage> createState() => _TeamsHomePageState();
}

class _TeamsHomePageState extends State<TeamsHomePage> {
  final List<Item> items = [];

  static const List<Widget> _widgetOptions = <Widget>[
    Employees.EmployeesHomePage(),
    TeamsHomePage(),
    Offices.OfficesHomePage(),
  ];

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the selected page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _widgetOptions[index]),
    );
  }

  // Fetch all Teams
  void _fetchTeams() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.14:3000/api/getAllTeams'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        items.clear();
        for (var item in data) {
          items.add(
            Item(
              id: item['id'],
              imagePath: item['imagePath'],
              name: item['name'],
              head: item['head Manager'],
              width: 60,
              height: 60,
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load Teams: ${response.statusCode}')),
      );
    }
  }

  // Add a new Team
  Future<void> _addTeam(String name, String imagePath, String head) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.14:3000/api/addTeam'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'imagePath': imagePath,
          'head': head,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final newTeam = jsonDecode(response.body);
        setState(() {
          items.add(
            Item(
              id: newTeam['teamId'], // Adjust based on your response
              imagePath: imagePath,
              name: name,
              head: head,
              width: 60,
              height: 60,
            ),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added successfully')),
        );
        _fetchTeams(); // Fetch updated list
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add Team: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while adding Team')),
      );
    }
  }

  // Update an existing Team
  Future<void> _updateTeam(
      int id, String name, String imagePath, String head) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.14:3000/api/updateTeam'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'name': name,
        'imagePath': imagePath,
        'head': head,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        items.removeWhere((item) => item.id == id);
        items.add(
          Item(
            id: id,
            name: name,
            imagePath: imagePath,
            head: head,
            width: 60,
            height: 60,
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update Team: ${response.statusCode}')),
      );
    }
  }

  // Delete an Team
  void _deleteItem(Item item) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.14:3000/api/deleteTeam'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{'id': item.id}),
    );

    if (response.statusCode == 200) {
      setState(() {
        items.remove(item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete Team: ${response.statusCode}')),
      );
    }
  }

  void _editItem(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Team Info'),
          content: TeamForm(
            initialName: item.name,
            initialImagePath: item.imagePath,
            initialHead: item.head,
            onSave: (name, imagePath, head) {
              _updateTeam(item.id, name, imagePath, head);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit cancelled')),
                );
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Team Info'),
          content: TeamForm(
            onSave: (name, imagePath, head) {
              _addTeam(name, imagePath, head);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add cancelled')),
                );
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text('Teams'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: _addItem,
                    tooltip: 'Add',
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                "assets/images/team.png",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onTap: () {
                  // Implement search logic if needed
                },
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: item.imagePath.startsWith('http') ||
                            item.imagePath.startsWith('https')
                        ? NetworkImage(item.imagePath) // For network images
                        : File(item.imagePath).existsSync()
                            ? FileImage(
                                File(item.imagePath)) // For local images
                            : AssetImage('assets/uploads/emp1.png')
                                as ImageProvider, // Fallback if image not found
                    radius: 30,
                  ),
                  title: Text(item.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.head),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editItem(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Employees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: 'Offices',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TeamForm extends StatefulWidget {
  final String? initialName;
  final String? initialImagePath;
  final String? initialHead;
  final void Function(String name, String imagePath, String head) onSave;

  const TeamForm({
    Key? key,
    this.initialName,
    this.initialImagePath,
    this.initialHead,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TeamForm> createState() => _TeamFormState();
}

class _TeamFormState extends State<TeamForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _imagePath;
  late String _head;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = widget.initialName ?? '';
    _imagePath = widget.initialImagePath ?? 'assets/uploads/default.png';
    _head = widget.initialHead ?? '';
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imagePath.isNotEmpty
                    ? FileImage(File(_imagePath)) // Display picked image
                    : null,
                child: _imagePath
                        .isEmpty // Show camera icon if no image is picked
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                    : null,
                backgroundColor: _imagePath.isEmpty
                    ? Colors.grey[300]
                    : null, // Optional: background color for indication
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Team Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value ?? '';
                },
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Head Manager'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a head manager';
                  }
                  return null;
                },
                onSaved: (value) {
                  _head = value ?? '';
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    widget.onSave(_name, _imagePath, _head);
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
