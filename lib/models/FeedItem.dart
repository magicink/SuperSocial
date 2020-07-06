import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedItem extends StatefulWidget {
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String content;
  final String type;
  final Timestamp timestamp;
  final String postId;
  final String postMediaUrl;

  const FeedItem({
    Key key,
    this.username,
    this.userPhotoUrl,
    this.content,
    this.type,
    this.timestamp,
    this.userId,
    this.postId,
    this.postMediaUrl,
  }) : super(key: key);

  factory FeedItem.fromDocument(DocumentSnapshot snapshot) {
    return new FeedItem(
      userId: snapshot['userId'],
      username: snapshot['username'],
      userPhotoUrl: snapshot['userPhotoUrl'],
      content: snapshot['content'],
      type: snapshot['type'],
      timestamp: snapshot['timestamp'],
      postId: snapshot['postId'],
      postMediaUrl: snapshot['postMediaUrl'],
    );
  }

  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
