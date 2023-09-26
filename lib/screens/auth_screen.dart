import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/widgets/auth/auth_form.dart';
import 'dart:io';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;
  Future<void> _submitUserInfo(
    String email,
    String username,
    String password,
    File image,
    bool isLogin,
  ) async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    try {
      UserCredential userCredential;

      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

        String imageUrl = '';
        await firebaseStorageRef.putFile(image).whenComplete(() async {
          imageUrl = await firebaseStorageRef.getDownloadURL();
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'username': username,
          'image_url': imageUrl,
        });
      }
    } on PlatformException catch (err) {
      var message = 'An error occured, please check your credentials.';
      if (err.message != null) {
        message = err.message!;
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (err) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print('Error adding user data to Firestore: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AuthForm(
          _submitUserInfo,
          isLoading,
        ),
      ),
    );
  }
}
