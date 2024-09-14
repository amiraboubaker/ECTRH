// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../employees/homePage.dart';
import '../home_screen.dart';
import '../teams/homePage.dart';

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

  final int id;
  final String imagePath;
  final String name;
  final String manager;
  final String location;
  final String fixNumber;
  final double width;
  final double height;
}

class OfficesHomePage extends StatefulWidget {
  const OfficesHomePage({super.key});

  @override
  State<OfficesHomePage> createState() => _OfficeHomePageState();
}

class _OfficeHomePageState extends State<OfficesHomePage> {
  final List<Item> items = [];
  static const List<Widget> _widgetOptions = <Widget>[
    EmployeesHomePage(),
    TeamsHomePage(),
    OfficesHomePage(),
  ];
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchOffice();
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

  Future<void> _fetchOffice() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/getAllOffice'));
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
          content: OfficeForm(
            initialName: item.name,
            initialManager: item.manager,
            initialLocation: item.location,
            initialImagePath: item.imagePath,
            initialFixNumber: item.fixNumber,
            onSave: (name, manager, location, imagePath, fixNumber) {
              _updateOffice(
                  item.id, name, manager, location, imagePath, fixNumber);
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
      Uri.parse('http://localhost:3000/api/deleteOffice'),
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
            content: Text('Failed to delete employee: ${response.statusCode}')),
      );
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Office Info'),
          content: OfficeForm(
            onSave: (name, manager, location, imagePath, fixNumber) {
              _addOffice(name, manager, location, imagePath, fixNumber);
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

  Future<void> _addOffice(String name, String manager, String location,
      String imagePath, String fixNumber) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/addOffice'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'manager': manager,
        'location': location,
        'imagePath': imagePath,
        'fixNumber': fixNumber,
      }),
    );

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
      print('Error: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to add employee: ${response.statusCode}')),
      );
    }
  }

  Future<void> _updateOffice(int id, String name, String manager,
      String location, String imagePath, String fixNumber) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/api/updateOffice'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'name': name,
        'manager': manager,
        'location': location,
        'imagePath': imagePath,
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
                  // title: Text(items[index].name),
                  subtitle: Text(
                    '${items[index].name}\'${items[index].location}\nManager: ${items[index].manager}\nFix Number: ${items[index].fixNumber}',
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

class OfficeForm extends StatefulWidget {
  const OfficeForm({
    Key? key,
    this.initialName,
    this.initialManager,
    this.initialLocation,
    this.initialFixNumber,
    this.initialImagePath,
    required Null Function(dynamic name, dynamic manager, dynamic location,
            dynamic imagePath, dynamic fixNumber)
        onSave,
  }) : super(key: key);

  final String? initialName;
  final String? initialManager;
  final String? initialLocation;
  final String? initialFixNumber;
  final String? initialImagePath;

  @override
  _OfficeFormState createState() => _OfficeFormState();

  void onSave(String name, String manager, String location, String imagePath,
      String fixNumber) {}
}

class _OfficeFormState extends State<OfficeForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _manager;
  late String _location;
  late String _fixNumber;
  late String _imagePath;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName ?? '';
    _manager = widget.initialManager ?? '';
    _location = widget.initialLocation ?? '';
    _fixNumber = widget.initialFixNumber ?? '';
    _imagePath = widget.initialImagePath ?? '';
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
                decoration: const InputDecoration(labelText: 'Office Name'),
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
                initialValue: _manager,
                decoration: const InputDecoration(labelText: 'Manager'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the manager\'s name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _manager = value ?? '';
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
                onSaved: (value) {
                  _location = value ?? '';
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                initialValue: _fixNumber,
                decoration: const InputDecoration(labelText: 'Fix Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the fix number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _fixNumber = value ?? '';
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
                        _name, _manager, _location, _imagePath, _fixNumber);
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
