import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String messageText;
  final String username;
  final String? avatarUrl;
  final bool ownMessage;
  final Key key;

  final _database = FirebaseFirestore.instance;

  MessageBubble({
    required this.messageText,
    required this.username,
    required this.avatarUrl,
    required this.ownMessage,
    required this.key,
  });

  Widget get _buildUserAvatar => Padding(
        padding: ownMessage
            ? const EdgeInsets.only(left: 8.0)
            : EdgeInsets.only(right: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white54,
          radius: 15,
          child: CircleAvatar(
            radius: 13,
            backgroundImage:
                avatarUrl == null ? null : NetworkImage(avatarUrl!),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          ownMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: ownMessage
                ? EdgeInsets.only(left: 64)
                : EdgeInsets.only(right: 64),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: ownMessage
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(ownMessage ? 16 : 2),
                  bottomRight: Radius.circular(ownMessage ? 2 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: ownMessage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!ownMessage) _buildUserAvatar,
                      Text(
                        username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (ownMessage) _buildUserAvatar,
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    messageText,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
