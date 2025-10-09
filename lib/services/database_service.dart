import 'package:chatting_app/models/user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  // Create user profile in Firestore
  static Future<void> createUserProfile({
    required UserDetails userDetails,
  }) async {
    try {
      await _firestore.collection('users').doc(userDetails.id).set({
        'username': userDetails.id,
        'email': userDetails.email,
        'firstName': userDetails.firstName,
        'lastName': userDetails.lastName,
        'age': userDetails.age,
        'profilePicUrl': userDetails.imageUrl,
        'city': userDetails.city,
        'gender': userDetails.gender,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  // Fetch user profile from Firestore
  static Future<UserDetails?> getUserProfile() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserDetails()
          ..id = doc['username'] ?? ''
          ..email = doc['email'] ?? ''
          ..firstName = doc['firstName'] ?? ''
          ..lastName = doc['lastName'] ?? ''
          ..age = doc['age'] ?? ''
          ..imageUrl = doc['profilePicUrl'] ?? ''
          ..city = doc['city'] ?? ''
          ..gender = doc['gender'] ?? '';
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }

  // send message to Firestore
  static Future<void> sendMessage(String message) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      UserDetails? userDetails = await getUserProfile();
      if (userId.isEmpty || userDetails == null) return;
      await _firestore.collection('messages').add({
        'text': message,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'firstName': userDetails.firstName,
        'profilePicUrl': userDetails.imageUrl,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
