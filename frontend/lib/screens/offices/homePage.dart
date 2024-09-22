import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../employees/homePage.dart' as Employees;
import '../home_screen.dart';
import '../teams/homePage.dart' as Teams;

class Item {
  Item({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.manager,
    required this.location,
    required this.fixNumber,
    this.width = 90.0,
    this.height = 90.0,
  });

  final String fixNumber;
  final double height;
  final int id;
  final String imagePath;
  final String location;
  final String manager;
  final String name;
  final double width;
}

class OfficesHomePage extends StatefulWidget {
  const OfficesHomePage({super.key});

  @override
  State<OfficesHomePage> createState() => _OfficesHomePageState();
}

class _OfficesHomePageState extends State<OfficesHomePage> {
  final List<Item> items = [];

  static const List<Widget> _widgetOptions = <Widget>[
    Employees.EmployeesHomePage(),
    Teams.TeamsHomePage(),
    OfficesHomePage(),
  ];

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchOffices();
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

  // Fetch all offices
  void _fetchOffices() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.14:3000/api/getAllOffices'));
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
              manager: item['manager'],
              location: item['location'],
              fixNumber: item['fixNumber'],
              width: 60,
              height: 60,
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load offices: ${response.statusCode}')),
      );
    }
  }

  // Add a new office
  Future<void> _addOffice(String imagePath, String name, String manager,
      String location, String fixNumber) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.14:3000/api/addOffice'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'imagePath': imagePath,
          'name': name,
          'manager': manager,
          'location': location,
          'fixNumber': fixNumber,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final newOffice = jsonDecode(response.body);
        setState(() {
          items.add(
            Item(
              id: newOffice['id'],
              imagePath: newOffice['imagePath'],
              name: newOffice['name'],
              manager: newOffice['manager'],
              location: newOffice['location'],
              fixNumber: newOffice['fixNumber'],
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
              content: Text('Failed to add office: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while adding office')),
      );
    }
  }

  // Update an existing office
  Future<void> _updateOffice(int id, String imagePath, String name,
      String manager, String location, String fixNumber) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.14:3000/api/updateOffice'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'imagePath': imagePath,
        'name': name,
        'manager': manager,
        'location': location,
        'fixNumber': fixNumber,
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
            manager: manager,
            location: location,
            fixNumber: fixNumber,
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
            content: Text('Failed to update office: ${response.statusCode}')),
      );
    }
  }

  // Delete an office
  void _deleteItem(Item item) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.14:3000/api/deleteOffice'),
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
            content: Text('Failed to delete office: ${response.statusCode}')),
      );
    }
  }

  void _editItem(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Office Info'),
          content: OfficeForm(
            initialImagePath: item.imagePath,
            initialName: item.name,
            initialManager: item.manager,
            initialLocation: item.location,
            initialFixNumber: item.fixNumber,
            onSave: (name, manager, location, fixNumber, imagePath) {
              _updateOffice(
                  item.id, name, manager, location, fixNumber, imagePath);
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
          title: const Text('Add Office Info'),
          content: OfficeForm(
            onSave: (imagePath, name, manager, location, fixNumber) {
              _addOffice(imagePath, name, manager, location, fixNumber);
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
                "assets/images/office.png",
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
                      Text(item.manager),
                      Text(item.location),
                      Text(item.fixNumber),
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
        selectedItemColor: const Color.fromARGB(255, 27, 20, 235),
        onTap: _onItemTapped,
      ),
    );
  }
}

class OfficeForm extends StatefulWidget {
  const OfficeForm({
    Key? key,
    this.initialImagePath,
    this.initialName,
    this.initialManager,
    this.initialLocation,
    this.initialFixNumber,
    required this.onSave,
  }) : super(key: key);

  final void Function(String imagePath, String name, String manager,
      String location, String fixNumber) onSave;

  final String? initialFixNumber;
  final String? initialImagePath;
  final String? initialLocation;
  final String? initialManager;
  final String? initialName;

  @override
  State<OfficeForm> createState() => _OfficeFormState();
}

class _OfficeFormState extends State<OfficeForm> {
  late TextEditingController _fixNumberController;
  final _formKey = GlobalKey<FormState>();
  late String _imagePath;
  late TextEditingController _locationController;
  late TextEditingController _managerController;
  late TextEditingController _nameController;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _managerController.dispose();
    _locationController.dispose();
    _fixNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _managerController =
        TextEditingController(text: widget.initialManager ?? '');
    _locationController =
        TextEditingController(text: widget.initialLocation ?? '');
    _fixNumberController =
        TextEditingController(text: widget.initialFixNumber ?? '');
    _imagePath = widget.initialImagePath ?? 'uploads/default.png';
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
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _imagePath != null
                    ? FileImage(File(_imagePath))
                    : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
                child: const Icon(Icons.camera_alt),
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Office Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the office name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _managerController,
                decoration: const InputDecoration(labelText: 'Manager'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the manager\'s name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _fixNumberController,
                decoration: const InputDecoration(labelText: 'Fix Number'),
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
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    widget.onSave(
                      _imagePath,
                      _nameController.text,
                      _managerController.text,
                      _locationController.text,
                      _fixNumberController.text,
                    );
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
