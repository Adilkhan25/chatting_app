import 'package:chatting_app/models/message.dart';
import 'package:chatting_app/services/database_service.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

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
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(message.senderProfilePicUrl),
              ),
              title: Text(message.senderName),
              subtitle: Text(message.text),
            );
          },
        );
      },
    );
    // return const Center(
    //   child: Text('Chat Messages'),
    // );
  }
}