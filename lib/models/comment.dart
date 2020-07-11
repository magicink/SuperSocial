import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String photoUrl;
  final Timestamp timestamp;
  final String comment;

  const Comment(
      {Key key,
        this.username,
        this.userId,
        this.photoUrl,
        this.timestamp,
        this.comment})
      : super(key: key);

  factory Comment.fromDocument(DocumentSnapshot snapshot) {
    return Comment(
        username: snapshot['username'],
        userId: snapshot['userId'],
        photoUrl: snapshot['photoUrl'],
        timestamp: snapshot['timestamp'],
        comment: snapshot['comment']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(photoUrl),
          ),
          title: Text(comment),
          subtitle: Text(timeAgo.format(timestamp.toDate())),
        ),
        Divider()
      ],
    );
  }
}