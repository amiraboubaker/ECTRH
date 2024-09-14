import 'package:flutter/material.dart'; 

Widget reusableTextField({
  required String text,
  required IconData icon,
  required bool isPasswordType,
  required TextEditingController controller,
  String? Function(String?)? validator, // Add validator parameter
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPasswordType,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white),
      labelText: text,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
    ),
    validator: validator, // Set the validator
  );
}

Widget signInSignUpButton({
  required BuildContext context,
  required bool isSignIn,
  required VoidCallback onTap,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0c588b),
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    onPressed: onTap,
    child: Text(
      isSignIn ? 'Sign In' : 'Sign Up',
      style: const TextStyle(fontSize: 16, color: Colors.white),
    ),
  );
}

Widget bottomNavigationBar({
  required BuildContext context,
  required int currentIndex,
  required ValueChanged<int> onTap,
}) {
  return BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
    currentIndex: currentIndex,
    selectedItemColor: const Color(0xFF0c588b),
    onTap: onTap,
  );
}
