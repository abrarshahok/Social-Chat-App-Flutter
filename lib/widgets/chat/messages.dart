import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/widgets/chat/message_bubble.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (ctx, streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = streamSnapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) => MessageBubble(
            text: chatDocs[index]['text'],
            userName: chatDocs[index]['username'],
            userImage: chatDocs[index]['image_url'],
            isMe: chatDocs[index]['userId'] == currentUserId,
          ),
        );
      },
    );
  }
}
