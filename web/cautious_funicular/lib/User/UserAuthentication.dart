import 'package:flutter/material.dart';

class UserAuthentication extends StatefulWidget {
  const UserAuthentication({super.key});

  @override
  State<UserAuthentication> createState() => _UserAuthentication();
}

class _UserAuthentication extends State<UserAuthentication> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

    bool _isNewUser = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Toggle Switch for New User or Existing User
          SwitchListTile(
            title: Text(_isNewUser ? "New User" : "Existing User"),
            value: _isNewUser,
            onChanged: (bool value) {
              setState(() {
                _isNewUser = value;
              });
            },
          ),
          // Email Input Field
          if(_isNewUser)
            TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20),
          // Username Input Field
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          // Password Input Field
          TextField(
            controller: _passwordController,
            obscureText: true, // Hides the password
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          // Confirm Password Input Field (if New User)
          if (_isNewUser)
            TextField(
              controller: _confirmPasswordController,
              obscureText: true, // Hides the password
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          SizedBox(height: 20),
          // Submit Button
          Center(
            child: ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ),
        ],
      ),
      ),
    );
  }

    // Method to handle form submission
  void _submitForm() {
    String email = _emailController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Example validation (can be expanded)
    if (_isNewUser && password != confirmPassword) {
      _showMessage('Passwords do not match');
    } else {
      // Handle registration logic here
      _showMessage('Form Submitted: $email, $username');
    }
  }

  // Utility function to show message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
