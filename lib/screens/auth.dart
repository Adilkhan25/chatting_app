import 'package:chatting_app/models/user_details.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/common/drop_down_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
// final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _userDetails = UserDetails();
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _isLoginMode ? await logInuser() : await createAuthenticUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Hang out'))),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png', fit: BoxFit.cover),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _userDetails.email = value ?? '';
                          },
                        ),
                        if (!_isLoginMode) ...signUpWidgets(),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _userDetails.password = value ?? '';
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                          child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                        ),
                        TextButton(
                          onPressed: () {
                            _formKey.currentState?.reset();
                            setState(() {
                              _isLoginMode = !_isLoginMode;
                            });
                          },
                          child: Text(
                            _isLoginMode
                                ? 'Create new account'
                                : 'I already have an account',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> signUpWidgets() {
    return [
      TextFormField(
        decoration: InputDecoration(labelText: 'First Name'),
        keyboardType: TextInputType.text,
        validator: (value) => (value == null || value.isEmpty)
            ? 'Please enter your first name'
            : null,
        onSaved: (value) => _userDetails.firstName = value ?? '',
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Last Name'),
        keyboardType: TextInputType.text,
        validator: (value) => (value == null || value.isEmpty)
            ? 'Please enter your last name'
            : null,
        onSaved: (value) => _userDetails.lastName = value ?? '',
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Age'),
        keyboardType: TextInputType.number,
        validator: (value) => (value == null || value.isEmpty)
            ? 'Please enter your age name'
            : null,
        onSaved: (value) => _userDetails.lastName = value ?? '',
      ),
      Row(
        children: [
          Dropdown(
            dropDownList: ['Male', 'Female', 'Other'],
            dropDownTitle: 'Gender',
            validator: (value) => value == null ? 'Please select gender' : null,
            onSaved: (value) => _userDetails.gender = value!,
          ),
          const Spacer(),
        ],
      ),
      Row(
        children: [
          Dropdown(
            dropDownList: [
              'Delhi',
              'Chennai',
              'Kolkata',
              'Mumbai',
              'Bangalore',
              'Hyderabad',
              'Pune',
              'Other',
            ],
            dropDownTitle: 'City',
            validator: (value) => value == null ? 'Please select city' : null,
            onSaved: (value) => _userDetails.city = value!,
          ),
          const Spacer(),
        ],
      ),
    ];
  }

  Future<void> createAuthenticUser() async {
    print('Creating user: ${_userDetails.email}, ${_userDetails.password}');
    // Add your sign-up logic here
    try {
      final registeredUser = await _auth.createUserWithEmailAndPassword(
        email: _userDetails.email,
        password: _userDetails.password,
      );
      print('User registered: $registeredUser');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User registered successfully!.')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    }
  }

  Future<void> logInuser() async {
    try {
      final loggedInUser = await _auth.signInWithEmailAndPassword(
        email: _userDetails.email,
        password: _userDetails.password,
      );
      print('User logged in: $loggedInUser');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    }
  }
}
