import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  final String currentUserId;
  final String friendUserId;

  const NewMessage({
    super.key,
    required this.currentUserId,
    required this.friendUserId,
  });
  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final messageController = TextEditingController();
  String enteredMessage = '';
  
  String get chatRoomId {
    if (widget.currentUserId.compareTo(widget.friendUserId) > 0) {
      return '${widget.currentUserId}-${widget.friendUserId}';
    }
    return '${widget.friendUserId}-${widget.currentUserId}';
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('messages')
        .add(
      {
        'senderId': widget.currentUserId,
        'text': enteredMessage,
        'image_url': userData['image_url'],
        'time': Timestamp.now(),
      },
    );
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Send a message...',
              ),
              onChanged: (typedMessage) {
                setState(() {
                  enteredMessage = typedMessage;
                });
              },
            ),
          ),
          IconButton(
            onPressed: enteredMessage.trim().isEmpty ||
                    messageController.text.trim().isEmpty
                ? null
                : _sendMessage,
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
