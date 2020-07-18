import 'package:SuperSocial/models/user.dart';
import 'package:SuperSocial/pages/comments.dart';
import 'package:SuperSocial/pages/home.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:SuperSocial/pages/profile.dart';

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
        postId: postId, postOwnerId: ownerId, postMediaUrl: mediaUrl);
  }));
}

class Post extends StatefulWidget {
  final String id;
  final String ownerId;
  final String ownerUsername;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final Timestamp timestamp;

  Post(
      {Key key,
      this.id,
      this.ownerId,
      this.ownerUsername,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.timestamp})
      : super(key: key);

  factory Post.fromDocument(DocumentSnapshot snapshot) {
    return Post(
        id: snapshot['uuid'],
        ownerId: snapshot['userUid'],
        ownerUsername: snapshot['username'],
        location: snapshot['location'],
        description: snapshot['caption'],
        mediaUrl: snapshot['mediaUrl'],
        likes: snapshot['likes'],
        timestamp: snapshot['timestamp']);
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
      likeCount: getLikeCount(this.likes),
      timestamp: this.timestamp);

  int getLikeCount(likes) {
    if (likes == null) return 0;
    int count = 0;
    likes.values.forEach((value) {
      if (value) count++;
    });
    return count;
  }
}

class _PostState extends State<Post> {
  String currentUserId = currentUser?.uid;
  String id;
  String ownerId;
  String ownerUsername;
  String location;
  String description;
  String mediaUrl;
  dynamic likes;
  int likeCount;
  Timestamp timestamp;

  bool busy = false;
  bool isLiked = false;

  Future<DocumentSnapshot> user;
  _PostState(
      {this.id,
      this.ownerId,
      this.ownerUsername,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.likeCount,
      this.timestamp});

  void addFeedItem() {
    feedRef.document(ownerId).collection('items').document(id).setData({
      'timestamp': DateTime.now().toUtc(),
      'type': 'like',
      'userId': currentUser.uid,
      'username': currentUser.username,
      'userPhotoUrl': currentUser.photoUrl,
      'postId': id,
      'postMediaUrl': mediaUrl,
      'content': ''
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[buildHeader(), buildImage(), buildFooter()],
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
              onTap: toggleLike,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => showComments(context,
                  postId: id, ownerId: ownerId, mediaUrl: mediaUrl),
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
              margin: EdgeInsets.only(left: 20.0, right: 20.0),
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
            onTap: () => Profile.showProfile(context, profileId: userData.uid),
            child: Text(userData.username,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () => handleDeletePost(context),
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  Widget buildImage() {
    return GestureDetector(
      onDoubleTap: toggleLike,
      child: Stack(
        children: <Widget>[Image.network(mediaUrl)],
      ),
    );
  }

  getUser() async {
    setState(() {
      busy = true;
    });
    user = usersRef.document(ownerId).get();
    await user.then((result) {
      setState(() {
        busy = false;
      });
      print(result);
      return;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser(); // Change
    isLiked = likes[currentUserId] == null ? false : likes[currentUserId];
  }

  void removeFeedItem() {
    var query = feedRef
        .document(ownerId)
        .collection('items')
        .where('userId', isEqualTo: currentUser.uid)
        .where('type', isEqualTo: 'like');
    var documents = query.getDocuments();
    documents.then((docs) {
      docs.documents.forEach((element) {
        if (element.exists) {
          element.reference.delete();
        }
      });
    });
  }

  void toggleLike() {
    bool currentUserLiked = likes[currentUserId] == true;
    userPostsRef
        .document(ownerId)
        .collection('posts')
        .document(id)
        .updateData({'likes.$currentUserId': !currentUserLiked});
    if (!currentUserLiked) {
      addFeedItem();
    } else {
      removeFeedItem();
    }
    setState(() {
      likeCount += currentUserLiked ? -1 : 1;
      likes[currentUserId] = !currentUserLiked;
      isLiked = !currentUserLiked;
    });
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(context: parentContext, builder: (context) {
      return SimpleDialog(
        title: Text('Remove this post?'),
        children: <Widget>[
          SimpleDialogOption(child: Text('Delete'),),
          SimpleDialogOption(child: Text('Cancel'), onPressed: () => Navigator.pop(context),)
        ],
      );
    });
  }
}
