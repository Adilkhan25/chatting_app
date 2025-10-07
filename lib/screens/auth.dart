import 'package:chatting_app/models/user_details.dart';
import 'package:chatting_app/services/auth_service.dart';
import 'package:chatting_app/services/database_service.dart';
import 'package:chatting_app/services/storage_service.dart';
import 'package:chatting_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/common/drop_down_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  bool isAuthenticating = false;
  final _formKey = GlobalKey<FormState>();
  final _userDetails = UserDetails();
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_isLoginMode && _userDetails.profilePic == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please pick the profile image')),
      );
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
                        if (_isLoginMode == false)
                          UserImagePicker(
                            onImagePicked: (pickedImage) =>
                                _userDetails.profilePic = pickedImage,
                          ),
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
                        if (isAuthenticating) CircularProgressIndicator(),
                        if (!isAuthenticating)
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                          child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                        ),
                        if (!isAuthenticating)
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
        onSaved: (value) => _userDetails.age = value ?? '',
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
      setState(() {
        isAuthenticating = true;
      });

      // Create user in Firebase Auth
      final registeredUser = await _auth.createUserWithEmailAndPassword(
        email: _userDetails.email,
        password: _userDetails.password,
      );
       _userDetails.id = registeredUser.user?.uid ?? '';
      // Create or sign in user in Supabase Auth and store image on Supabase Storage
      final profileImageUrl = await StorageService.uploadProfilePictureFromFile(
        _userDetails.profilePic!,
      );
      _userDetails.imageUrl = profileImageUrl;
      
      // Store additional user details in Firestore
      await DatabaseService.createUserProfile(
        userDetails: _userDetails,
      );
      print('Profile Image URL: $profileImageUrl');
      print('User registered: $registeredUser');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User registered successfully!.')));
    } on FirebaseAuthException catch (e) {
      setState(() {
        isAuthenticating = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    }
  }

  Future<void> logInuser() async {
    try {
      setState(() {
        isAuthenticating = true;
      });
      final loggedInUser = await _auth.signInWithEmailAndPassword(
        email: _userDetails.email,
        password: _userDetails.password,
      );
      await AuthService.signInExistingSupabaseUser();
      print('User logged in: $loggedInUser');
    } on FirebaseAuthException catch (e) {
      setState(() {
        isAuthenticating = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    }
  }
}
