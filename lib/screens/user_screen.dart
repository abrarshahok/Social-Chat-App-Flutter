import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/widgets/chat/messages.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final userInfoStream =
        FirebaseFirestore.instance.collection('users').snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Chat App'),
        elevation: 1,
        actions: [
          DropdownButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            items: const [
              DropdownMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.blue,
                    ),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onChanged: (identifier) {
              if (identifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: userInfoStream,
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final userDocs = streamSnapshot.data!.docs;
          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final friendUserId = userDocs[index].id;
              final userEmail = userDocs[index]['email'];
              final userImage = userDocs[index]['image_url'];
              final userName = userDocs[index]['username'];
              if (currentUserId != friendUserId) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(userImage),
                    ),
                    title: Text(userName),
                    subtitle: Text(userEmail),
                    onTap: () => Navigator.of(context).pushNamed(
                      Messages.routeName,
                      arguments: {
                        'currentUserId': currentUserId,
                        'friendUserId': friendUserId,
                        'userName': userName,
                      },
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}
