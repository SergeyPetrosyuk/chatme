import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File imageFile) onImagePicked;

  const UserImagePicker({required this.onImagePicked});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  final imagePicker = ImagePicker();
  File? _pickedImage;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _pickImage,
        child: CircleAvatar(
          radius: 150,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
      );

  void _pickImage() async {
    try {
      XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final imageFile = File(file.path);
        widget.onImagePicked(imageFile);
        setState(() => _pickedImage = imageFile);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Can\'t pick an image'),
        ));
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Can\'t pick an image. ${e.message}'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Can\'t pick an image'),
      ));
    }
  }
}
