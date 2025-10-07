import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;
  // Converts Firebase UID to a unique, email-safe SHA256 string
  static String _uidToEmail(String uid) {
    final hash = sha256.convert(utf8.encode(uid)).toString();
    return hash;
  }

  static Future<String> createSupabaseUserForFirebase() async {
    final firebaseUser = FirebaseAuth.instance.currentUser!;
    // Create a valid email format using Firebase UID
    final userSha256 = _uidToEmail(firebaseUser.uid);
    final supabaseEmail = firebaseUser.email;
    final supabasePassword = 'fb_${userSha256}_pw';

    final response = await _supabase.auth.signUp(
      email: supabaseEmail,
      password: supabasePassword,
      data: {
        'firebase_uid': userSha256,
        'firebase_email': firebaseUser.email,
        'created_via': 'firebase_sync',
      },
    );

    if (response.user == null) {
      throw Exception("Failed to create Supabase user");
    }

    print('✅ Created Supabase user: ${response.user!.id}');
    return response.user!.id;
  }

  static Future<String?> signInExistingSupabaseUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser!;

    // Use the same email format for sign in
    // Create a valid email format using Firebase UID
    final userSha256 = _uidToEmail(firebaseUser.uid);
    final supabaseEmail = firebaseUser.email;
    final supabasePassword = 'fb_${userSha256}_pw';
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: supabaseEmail,
        password: supabasePassword,
      );

      print('✅ Signed in existing Supabase user: ${response.user?.id}');
      return response.user?.id;
    } catch (e) {
      print('❌ Error signing in Supabase user: $e');
      return null;
    }
  }

  static String? getSupabaseUserId() {
    return _supabase.auth.currentUser?.id;
  }

  static bool isSupabaseAuthenticated() {
    final session = _supabase.auth.currentSession;
    return session != null && session.accessToken.isNotEmpty;
  }
}
