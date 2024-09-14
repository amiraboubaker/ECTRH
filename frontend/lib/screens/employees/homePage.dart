import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../home_screen.dart';
import '../offices/homePage.dart' as Offices;
import '../teams/homePage.dart' as Teams;

class Item {
  Item({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.position,
    required this.email,
    required this.phoneNumber,
    this.width = 90.0,
    this.height = 90.0,
  });

  final int id;
  final String imagePath;
  final String name;
  final String position;
  final String email;
  final String phoneNumber;
  final double width;
  final double height;
}

class EmployeesHomePage extends StatefulWidget {
  const EmployeesHomePage({super.key});

  @override
  State<EmployeesHomePage> createState() => _EmployeesHomePageState();
}

class _EmployeesHomePageState extends State<EmployeesHomePage> {
  final List<Item> items = [];

  static const List<Widget> _widgetOptions = <Widget>[
    EmployeesHomePage(),
    Teams.TeamsHomePage(),
    Offices.OfficesHomePage(),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
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

  // Fetch all employees
  void _fetchEmployees() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/api/getAllEmployees'));
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
              position: item['position'],
              email: item['email'],
              phoneNumber: item['phoneNumber'],
              width: 60,
              height: 60,
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load employees: ${response.statusCode}')),
      );
    }
  }

  // Add a new employee
  Future<void> _addEmployee(String name, String email, String position,
      String phoneNumber, String imagePath) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/addEmployee'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'email': email,
        'position': position,
        'phoneNumber': phoneNumber,
        'imagePath': imagePath,
      }),
    );

    if (response.statusCode == 200) {
      final newEmployee = jsonDecode(response.body);
      setState(() {
        items.add(
          Item(
            id: newEmployee['id'],
            imagePath: newEmployee['imagePath'],
            name: newEmployee['name'],
            email: newEmployee['email'],
            position: newEmployee['position'],
            phoneNumber: newEmployee['phoneNumber'],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to add employee: ${response.statusCode}')),
      );
    }
  }

  // Update an existing employee
  Future<void> _updateEmployee(int id, String name, String email,
      String position, String phoneNumber, String imagePath) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/api/updateEmployee'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'position': position,
        'imagePath': imagePath,
        'phoneNumber': phoneNumber,
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
            email: email,
            position: position,
            phoneNumber: phoneNumber,
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
            content: Text('Failed to update employee: ${response.statusCode}')),
      );
    }
  }

  // Delete an employee
  void _deleteItem(Item item) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/api/deleteEmployee'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete employee: ${response.statusCode}')),
      );
    }
  }

  void _editItem(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Employee Info'),
          content: EmployeeForm(
            initialName: item.name,
            initialEmail: item.email,
            initialPosition: item.position,
            initialPhoneNumber: item.phoneNumber,
            initialImagePath: item.imagePath,
            onSave: (name, email, position, phoneNumber, imagePath) {
              _updateEmployee(
                  item.id, name, email, position, phoneNumber, imagePath);
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
          title: const Text('Add Employee Info'),
          content: EmployeeForm(
            onSave: (name, email, position, phoneNumber, imagePath) {
              _addEmployee(name, email, position, phoneNumber, imagePath);
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
        title: const Text('Offices'),
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
                "assets/images/employees.png",
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
                  leading: CircleAvatar(
                    radius: items[index].width / 2,
                    backgroundImage: NetworkImage(items[index]
                        .imagePath), // Use NetworkImage or FileImage as needed
                    child: items[index].imagePath.isEmpty
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                  title: Text(items[index].name),
                  subtitle: Text(
                    '${items[index].name}\nEmail: ${items[index].email}\nPosition: ${items[index].position}\nPhone Number: ${items[index].phoneNumber}',
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

class EmployeeForm extends StatefulWidget {
  const EmployeeForm({
    Key? key,
    this.initialName,
    this.initialEmail,
    this.initialPosition,
    this.initialPhoneNumber,
    this.initialImagePath,
    required this.onSave,
  }) : super(key: key);

  final String? initialName;
  final String? initialEmail;
  final String? initialPosition;
  final String? initialPhoneNumber;
  final String? initialImagePath;
  final void Function(
    String name,
    String email,
    String position,
    String phoneNumber,
    String imagePath,
  ) onSave;

  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _position;
  late String _phoneNumber;
  String _imagePath = 'assets/images/default.jpg';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = widget.initialName ?? '';
    _email = widget.initialEmail ?? '';
    _position = widget.initialPosition ?? '';
    _phoneNumber = widget.initialPhoneNumber ?? '';
    _imagePath = widget.initialImagePath ?? 'assets/images/default.jpg';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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
            SizedBox(height: 16),
            Form(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Name'),
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
                    TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value ?? '';
                      },
                    ),
                    TextFormField(
                      initialValue: _position,
                      decoration: const InputDecoration(labelText: 'Position'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a position';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _position = value ?? '';
                      },
                    ),
                    TextFormField(
                      initialValue: _phoneNumber,
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _phoneNumber = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          widget.onSave(_name, _email, _position, _phoneNumber,
                              _imagePath);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
