import 'dart:io';

import 'package:chatme/profile/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProfileRoute extends StatefulWidget {
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final database = FirebaseFirestore.instance;

  @override
  _ProfileRouteState createState() => _ProfileRouteState();
}

class _ProfileRouteState extends State<ProfileRoute> {
  File? _imageFile;

  void _onImagePicked(File file) {
    print(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                UserImagePicker(onImagePicked: _onImagePicked),
                _buildUserDataWidget(),
              ],
            ),
          )),
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
            return Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
