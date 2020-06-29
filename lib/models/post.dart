import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String id;
  final String ownerId;
  final String ownerUsername;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({this.id,
    this.ownerId,
    this.ownerUsername,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes});

  factory Post.fromDocument(DocumentSnapshot snapshot) {
    return Post(
        id: snapshot['id'],
        ownerId: snapshot['ownerId'],
        ownerUsername: snapshot['ownerUsername'],
        location: snapshot['location'],
        description: snapshot['description'],
        mediaUrl: snapshot['mediaUrl'],
        likes: snapshot['likes']);
  }

  int getLikeCount(likes) {
    if (likes == null) return 0;
    int count = 0;
    likes.values.forEach((value) {
      count++;
    });
    return count;
  }

  @override
  _PostState createState() =>
      _PostState(
          id: this.id,
          ownerId: this.ownerId,
          ownerUsername: this.ownerUsername,
          location: this.location,
          description: this.description,
          mediaUrl: this.mediaUrl,
          likes: this.likes,
          likeCount: getLikeCount(this.likes)
      );
}

class _PostState extends State<Post> {
  final String id;
  final String ownerId;
  final String ownerUsername;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final int likeCount;

  _PostState({this.id,
    this.ownerId,
    this.ownerUsername,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

