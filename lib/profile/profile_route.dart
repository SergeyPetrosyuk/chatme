import 'dart:io';

import 'package:chatme/profile/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';

class ProfileRoute extends StatefulWidget {
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final database = FirebaseFirestore.instance;

  @override
  _ProfileRouteState createState() => _ProfileRouteState();
}

class _ProfileRouteState extends State<ProfileRoute> {

  void _onImagePicked(File file) async {
    print(file.path);
    final uid = widget.auth.currentUser!.uid;
    final type = (mime(file.path) ?? 'image/jpg').split('/')[1];
    final ref =
        widget.storage.ref().child('profile-images').child('$uid.$type');

    ref.putFile(file).whenComplete(() => {});
    final imageUrl = await ref.getDownloadURL();

    await widget.database.collection('users').doc(uid).set(
      {'avatar': imageUrl},
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(child: _buildUserDataWidget()),
      ),
    );
  }

  Widget _buildUserDataWidget() {
    final String uid = widget.auth.currentUser!.uid;
    final Future userFuture =
        widget.database.collection('users').doc(uid).get();
    return FutureBuilder(
      future: userFuture,
      builder: (
        builderContext,
        snapshot,
      ) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            final data =
                (snapshot.data as DocumentSnapshot<Map<String, dynamic>>)
                        .data() ??
                    {};
            final username = data['username'];
            final email = data['email'];
            final avatar = data['avatar'];

            return Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserImagePicker(
                    onImagePicked: _onImagePicked,
                    avatarUrl: avatar,
                  ),
                  SizedBox(height: 16),
                  Text(
                    username,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            );
          }
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          final error = snapshot.error;
          return Center(
            child: Text((error as FirebaseException).message ?? 'error'),
          );
        }

        return Container();
      },
    );
  }
}
