import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../employees/homePage.dart';
import '../home_screen.dart';
import '../offices/homePage.dart';

class Item {
  Item({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.head,
    this.width = 90.0,
    this.height = 90.0,
  });

  final double height;
  final int id;
  final String imagePath;
  final String name;
  final String head;
  final double width;
}

class TeamsHomePage extends StatefulWidget {
  const TeamsHomePage({super.key});

  @override
  State<TeamsHomePage> createState() => _TeamsHomePageState();
}

class _TeamsHomePageState extends State<TeamsHomePage> {
  List<Item> items = [];

  static const List<Widget> _widgetOptions = <Widget>[
    EmployeesHomePage(),
    TeamsHomePage(),
    OfficesHomePage(),
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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _widgetOptions[index]),
    );
  }

  Future<void> _fetchTeam() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/getAllTeams'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        items.clear();
        for (var item in data) {
          items.add(
            Item(
              id: item['id'],
              imagePath: item['imagePath'] ?? 'assets/images/default.jpg',
              name: item['name'],
              head: item['head'],
              width: 60,
              height: 60,
            ),
          );
        }
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to fetch employees: ${response.statusCode}')),
      );
    }
  }

  void _editItem(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Office Info'),
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

  void _deleteItem(Item item) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/api/deleteTeam'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'id': item.id,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        items.remove(item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete Team: ${response.statusCode}')),
      );
    }
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

  Future<void> _addTeam(String name, String imagePath, String head) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/addteam'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'imagePath': imagePath,
        'head': head,
      }),
    );

    if (response.statusCode == 200) {
      final newTeam = jsonDecode(response.body);
      setState(() {
        items.add(
          Item(
            id: newTeam['id'],
            imagePath: newTeam['imagePath'],
            name: newTeam['name'],
            head: newTeam['head'],
            width: 60,
            height: 60,
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added successfully')),
      );
      Navigator.of(context).pop();
    } else {
      print('Error: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add team: ${response.statusCode}')),
      );
    }
  }

  Future<void> _updateTeam(
      int id, String name, String imagePath, String head) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/api/updateTeam'),
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
            imagePath: imagePath,
            name: name,
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
      // Handle error
    }
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
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      color: Colors.grey.shade200,
                      width: items[index].width,
                      height: items[index].height,
                      child: Image.network(
                        items[index].imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(items[index].name),
                  subtitle: Text(
                    '${items[index].name}\'${items[index].imagePath}\n',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Edit') {
                        _editItem(items[index]);
                      } else if (value == 'Delete') {
                        _deleteItem(items[index]);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Edit', 'Delete'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
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
            icon: Icon(Icons.people),
            label: 'Employees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Offices',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _fetchTeams {}

class TeamForm extends StatefulWidget {
  const TeamForm({
    Key? key,
    this.initialName,
    this.initialImagePath,
    this.initialHead,
    required Null Function(dynamic name, dynamic imagePath, dynamic head)
        onSave,
  }) : super(key: key);

  final String? initialName;
  final String? initialImagePath;
  final String? initialHead;

  @override
  _TeamFormState createState() => _TeamFormState();

  void onSave(String name, String imagePath, String head) {}
}

class _TeamFormState extends State<TeamForm> {
  final _formKey = GlobalKey<FormState>();
  late String _imagePath;
  late String _head;
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName ?? '';
    _imagePath = widget.initialImagePath ?? '';
    _head = widget.initialHead ?? '';
  }

  Future<void> _pickImage() async {
    // Use file picker to select an image
    // Update _imagePath with the selected image path
    // Uncomment and use a package like image_picker for actual implementation
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imagePath.isEmpty ? null : FileImage(File(_imagePath)),
                child: _imagePath.isEmpty
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                initialValue: _head,
                decoration: const InputDecoration(labelText: 'Team Head'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a head Team';
                  }
                  return null;
                },
                onSaved: (value) {
                  _head = value ?? '';
                },
              ),
            ),
            SizedBox(height: 16.0),
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
