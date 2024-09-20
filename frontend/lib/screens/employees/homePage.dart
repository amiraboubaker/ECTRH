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
    final response = await http
        .get(Uri.parse('http://192.168.1.14:3000/api/getAllEmployees'));
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
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.14:3000/api/addEmployee'),
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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while adding employee')),
      );
    }
  }

  // Update an existing employee
  Future<void> _updateEmployee(int id, String name, String email,
      String position, String phoneNumber, String imagePath) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.14:3000/api/updateEmployee'),
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
      Uri.parse('http://192.168.1.14:3000/api/deleteEmployee'),
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
        title: const Text('Employees'),
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
                      Text(item.position),
                      Text(item.email),
                      Text(item.phoneNumber),
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

class EmployeeForm extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;
  final String? initialPosition;
  final String? initialPhoneNumber;
  final String? initialImagePath;
  final void Function(String name, String email, String position,
      String phoneNumber, String imagePath) onSave;

  const EmployeeForm({
    Key? key,
    this.initialName,
    this.initialEmail,
    this.initialPosition,
    this.initialPhoneNumber,
    this.initialImagePath,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _position;
  late String _phoneNumber;
  late String _imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = widget.initialName ?? '';
    _email = widget.initialEmail ?? '';
    _position = widget.initialPosition ?? '';
    _phoneNumber = widget.initialPhoneNumber ?? '';
    _imagePath = widget.initialImagePath ?? 'assets/uploads/default.png';
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
                decoration: const InputDecoration(labelText: 'Employee Name'),
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
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Email';
                  } else if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                initialValue: _position,
                decoration: const InputDecoration(labelText: 'Work Position'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Work Position';
                  }
                  return null;
                },
                onSaved: (value) {
                  _position = value ?? '';
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                initialValue: _phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.number,
                maxLength: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Phone Number';
                  } else if (value.length > 8) {
                    return 'Phone number cannot exceed 8 digits';
                  } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Phone number must be numeric';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value ?? '';
                },
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    widget.onSave(
                        _name, _email, _position, _phoneNumber, _imagePath);
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
