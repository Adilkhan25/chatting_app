import 'package:chatting_app/models/message.dart';
import 'package:chatting_app/services/database_service.dart';
import 'package:chatting_app/widgets/chat_message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  
  Future<void> setUpPushNotifications() async {
    // Placeholder for push notification setup logic
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    print("FCM Token: $token");
  }

  @override
  void initState() {
    super.initState();
    setUpPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: DatabaseService.getMessagesStream(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }
        final messages = snapshot.data!;
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (ctx, index) {
            final message = messages[index];
            final isMe =
                message.senderId == FirebaseAuth.instance.currentUser?.uid;
            final isFirstInSequence = index + 1 < messages.length
                ? messages[index + 1].senderId != message.senderId
                : true;
            if (isFirstInSequence) {
              return MessageBubble.first(
                key: ValueKey(
                  message.text + message.senderId + index.toString(),
                ),
                userImage: message.senderProfilePicUrl,
                username: message.senderName,
                message: message.text,
                isMe: isMe,
              );
            } else {
              return MessageBubble.next(
                key: ValueKey(
                  message.text + message.senderId + index.toString(),
                ),
                message: message.text,
                isMe: isMe,
              );
            }
          },
        );
      },
    );
  }
}
