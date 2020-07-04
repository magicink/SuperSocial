import 'package:SuperSocial/pages/home.dart';
import 'package:SuperSocial/widgets/header.dart';
import 'package:SuperSocial/widgets/progress.dart';
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

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  const Comments({Key key, this.postId, this.postOwnerId, this.postMediaUrl})
      : super(key: key);

  @override
  CommentsState createState() => CommentsState(
      postId: postId, postOwnerId: postOwnerId, postMediaUrl: postMediaUrl);
}

class CommentsState extends State<Comments> {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  var commentController = TextEditingController();
  Stream<QuerySnapshot> comments;

  CommentsState({this.postId, this.postOwnerId, this.postMediaUrl});

  void addComment() {
    commentsRef.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timestamp': DateTime.now().toUtc(),
      'photoUrl': currentUser.photoUrl,
      'userId': currentUser.uid
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Write a comment'),
            ),
            trailing: OutlineButton(
              borderSide: BorderSide.none,
              onPressed: addComment,
              child: Text('Post'),
            ),
          )
        ],
      ),
    );
  }

  buildComments() {
    return StreamBuilder(
      stream: comments,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  getComments() {
    comments = commentsRef
        .document(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
  }
}
