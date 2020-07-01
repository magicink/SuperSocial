import 'package:SuperSocial/models/user.dart';
import 'package:SuperSocial/pages/home.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  Post(
      {this.id,
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
  _PostState createState() => _PostState(
      id: this.id,
      ownerId: this.ownerId,
      ownerUsername: this.ownerUsername,
      location: this.location,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      likeCount: getLikeCount(this.likes));
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

  _PostState(
      {this.id,
      this.ownerId,
      this.ownerUsername,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.likeCount});

  bool busy = false;
  Future<DocumentSnapshot> user;

  getUser() {
    setState(() {
      busy = true;
    });
    user = usersRef.document(ownerId).get();
    setState(() {
      busy = false;
    });
  }

  Widget buildHeader() {
    return FutureBuilder(
      future: user,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);
        User userData = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userData.photoUrl),
          ),
          title: GestureDetector(
            onTap: () => print('showing profile'),
            child: Text(userData.username,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () => print('deleting post'),
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  Widget buildImage() {
    return GestureDetector(
      onDoubleTap: () => print('liking post'),
      child: Stack(
        children: <Widget>[Image.network(mediaUrl)],
      ),
    );
  }

  Widget buildFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 30.0),
            ),
            GestureDetector(
              onTap: () => print('liking post'),
              child: Icon(
                Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => print('showing comments'),
              child: Icon(
                Icons.comment,
                size: 28.0,
                color: Colors.blue,
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text("$likeCount likes"),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$ownerUsername",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(description),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[buildHeader(), buildImage(), buildFooter()],
    );
  }
}
