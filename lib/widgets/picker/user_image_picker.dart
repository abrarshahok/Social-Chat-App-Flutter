import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File image) pickeImage;
  const UserImagePicker(this.pickeImage, {super.key});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? image;
  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() {
      image = File(pickedImage.path);
    });
    widget.pickeImage(image!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: image != null ? FileImage(image!) : null,
        ),
        TextButton(
          onPressed: pickImage,
          child: const Text('Add an Image.'),
        ),
      ],
    );
  }
}
