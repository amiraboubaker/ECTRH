import 'package:flutter/material.dart';

import '../auth/signin_screen.dart';

class Item {
  final String imagePath;
  final String title;
  final String description;
  final double width;
  final double height;

  Item({
    required this.imagePath,
    required this.title,
    required this.description,
    this.width = 50.0,
    this.height = 50.0,
  });
}

class DesignHomePage extends StatefulWidget {
  const DesignHomePage({super.key});

  @override
  State<DesignHomePage> createState() => _DesignHomePageState();
}

class _DesignHomePageState extends State<DesignHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Item> items = [
    Item(
        imagePath: 'assets/images/emp1.jpeg',
        title: 'Item 1',
        description: 'Description for item 1',
        width: 60,
        height: 60),
    Item(
        imagePath: 'assets/images/emp2.jpeg',
        title: 'Item 2',
        description: 'Description for item 2',
        width: 70,
        height: 70),
    Item(
        imagePath: 'assets/images/emp3.jpeg',
        title: 'Item 3',
        description: 'Description for item 3',
        width: 50,
        height: 50),
    Item(
        imagePath: 'assets/images/emp4.jpeg',
        title: 'Item 4',
        description: 'Description for item 4',
        width: 80,
        height: 80),
    Item(
        imagePath: 'assets/images/emp5.jpg',
        title: 'Item 5',
        description: 'Description for item 5',
        width: 60,
        height: 60),
    Item(
        imagePath: 'assets/images/emp6.jpg',
        title: 'Item 6',
        description: 'Description for item 6',
        width: 70,
        height: 70),
    Item(
        imagePath: 'assets/images/emp7.jpg',
        title: 'Item 7',
        description: 'Description for item 7',
        width: 50,
        height: 50),
    Item(
        imagePath: 'assets/images/emp8.jpg',
        title: 'Item 8',
        description: 'Description for item 8',
        width: 80,
        height: 80),
    Item(
        imagePath: 'assets/images/emp9.jpg',
        title: 'Item 9',
        description: 'Description for item 9',
        width: 60,
        height: 60),
    Item(
        imagePath: 'assets/images/emp10.jpg',
        title: 'Item 10',
        description: 'Description for item 10',
        width: 70,
        height: 70),
  ];

  void _editItem(Item item) {
    // Implémentez la logique pour éditer l'item ici.
    // Par exemple, afficher un dialogue avec des champs pour modifier l'image, le titre et la description.
    print("Edit item: ${item.title}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Design'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                "assets/images/Design.jpg",
                height: 400,
              ), // Assurez-vous d'avoir un logo dans votre dossier assets
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onTap: () {
                  // Logique de recherche à implémenter
                },
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      color: Colors
                          .grey.shade200, // Background color for the image
                      width: items[index].width,
                      height: items[index].height,
                      child: Image.asset(
                        items[index].imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(items[index].title),
                  subtitle: Text(items[index].description),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editItem(items[index]);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Edit', 'Delete'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice.toLowerCase(),
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                  onTap: () {
                    // Logique lors du tap sur un élément
                  },
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
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // FirebaseAuth.instance.signOut().then((value) {
          print("Signed Out");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
          // }).catchError((error) {
          //   print("Sign Out Error: $error");
          //   // Gérer les erreurs de déconnexion ici
          // });
        },
        tooltip: 'Logout',
        child: Icon(Icons.exit_to_app),
      ),
    );
  }
}
