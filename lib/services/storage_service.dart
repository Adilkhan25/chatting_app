import 'dart:io';

import 'package:chatting_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class StorageService {
  static final _supabase = Supabase.instance.client;
  static const String bucketName = 'profile-pic';
  
  static Future<String> uploadProfilePictureFromFile(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    
    String? userId = AuthService.getSupabaseUserId();
    if (userId == null || !AuthService.isSupabaseAuthenticated()) {
      userId = await AuthService.createSupabaseUserForFirebase();
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '$userId/profile_$timestamp.jpg';
    
    await _supabase.storage.from(bucketName).uploadBinary(
      filePath,
      bytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: true,
      ),
    );
    
    return _supabase.storage.from(bucketName).getPublicUrl(filePath);
  }
}