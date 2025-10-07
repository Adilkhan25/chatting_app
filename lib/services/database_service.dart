import 'package:chatting_app/models/user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
