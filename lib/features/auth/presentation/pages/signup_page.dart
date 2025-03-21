
import 'package:flutter/material.dart';
import '../../../../core/enums/role.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  Role _selectedRole = Role.student;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  bool _showAdminCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter password' : null,
              ),
              DropdownButtonFormField<Role>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                ),
                items: Role.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (Role? value) {
                  setState(() {
                    _selectedRole = value!;
                    _showAdminCode = value == Role.admin;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_showAdminCode)
                Column(
                  children: [
                    TextFormField(
                      controller: _adminCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Admin Code',
                        border: OutlineInputBorder(),
                        hintText: 'Enter admin verification code',
                      ),
                      obscureText: true,
                      validator: (value) => _showAdminCode && (value?.isEmpty ?? true)
                          ? 'Please enter admin code'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Admin registration requires verification code',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              if (_showAdminCode)
                TextFormField(
                  controller: _adminCodeController,
                  decoration: const InputDecoration(labelText: 'Admin Code'),
                  validator: (value) => _showAdminCode && (value?.isEmpty ?? true)
                      ? 'Please enter admin code'
                      : null,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSignUp,
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Temporary Credentials:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Student: student@test.com / student123'),
                      Text('Teacher: teacher@test.com / teacher123'),
                      Text('Admin: admin@test.com / admin123'),
                      Text('Admin Code: ADMIN123'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement sign up logic with role and admin code verification
      if (_selectedRole == Role.admin && _adminCodeController.text != 'ADMIN123') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid admin code')),
        );
        return;
      }
      // Proceed with signup...
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }
}
