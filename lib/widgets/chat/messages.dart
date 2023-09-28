import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_chat_app/widgets/chat/new_message.dart';
import '/widgets/chat/message_bubble.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  static const routeName = '/Message-Screen';

  String getChatRoomId(String currentUserId, String friendUserId) {
    if (currentUserId.compareTo(friendUserId) > 0) {
      return '$currentUserId-$friendUserId';
    }
    return '$friendUserId-$currentUserId';
  }

  @override
  Widget build(BuildContext context) {
    final modalData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String currentUserId = modalData['currentUserId'];
    final String friendUserId = modalData['friendUserId'];
    final String userName = modalData['userName'];
    final chatRoomId = getChatRoomId(currentUserId, friendUserId);
    final collectionReference = FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('messages');

    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        elevation: 1,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StreamBuilder(
            stream: collectionReference.snapshots(),
            builder: (ctx, streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              var chatDocs = streamSnapshot.data!.docs;
              chatDocs.sort(((a, b) => b['time'].compareTo(a['time'])));
              return Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    return MessageBubble(
                      text: chatDocs[index]['text'],
                      userImage: chatDocs[index]['image_url'],
                      userName: chatDocs[index]['senderId'] == currentUserId
                          ? 'You'
                          : userName,
                      isMe: chatDocs[index]['senderId'] == currentUserId,
                    );
                  },
                ),
              );
            },
          ),
          NewMessage(
            currentUserId: currentUserId,
            friendUserId: friendUserId,
          ),
        ],
      ),
    );
  }
}
