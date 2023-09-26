import 'dart:io';
import '/widgets/picker/user_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String username,
    String password,
    File image,
    bool isLogin,
  ) submitInfo;
  final bool isLoading;
  const AuthForm(this.submitInfo, this.isLoading, {super.key});
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLogin = true;
  String? userEmail;
  String? userName;
  String? userPassword;
  File? userImage;

  void _pickImage(File image) {
    userImage = image;
  }

  void _submitUserInfo() {
    bool isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (userImage == null && !isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No image picked!'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitInfo(
        userEmail!,
        !isLogin ? userName! : '',
        userPassword!,
        !isLogin ? userImage! : File(''),
        isLogin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLogin) UserImagePicker(_pickImage),
              TextFormField(
                key: const ValueKey('email'),
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (typedEmail) => userEmail = typedEmail,
                validator: (value) {
                  if (value!.trim().isEmpty || !value.contains('@')) {
                    return 'Please Enter Valid Email!';
                  }
                  return null;
                },
              ),
              if (!isLogin)
                TextFormField(
                  key: const ValueKey('username'),
                  decoration: const InputDecoration(labelText: 'Username'),
                  onSaved: (typedUserName) => userName = typedUserName,
                  validator: (value) {
                    if (value!.trim().isEmpty || value.length < 4) {
                      return 'Please Enter valid username, minimum 4 characters.';
                    }
                    return null;
                  },
                ),
              TextFormField(
                key: const ValueKey('password'),
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onSaved: (typedPassword) => userPassword = typedPassword,
                validator: (value) {
                  if (value!.trim().isEmpty || value.length < 7) {
                    return 'Please enter valid password, minimum 7 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              widget.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: _submitUserInfo,
                      child: Text(isLogin ? 'Login' : 'Signup'),
                    ),
              TextButton(
                onPressed: () => setState(() {
                  isLogin = !isLogin;
                }),
                child: Text(
                  isLogin ? 'Create an account' : 'Already Have an Account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
