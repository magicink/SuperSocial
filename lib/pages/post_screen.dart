import 'package:SuperSocial/models/post.dart';
import 'package:SuperSocial/pages/home.dart';
import 'package:SuperSocial/widgets/header.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  const PostScreen({Key key, this.postId, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPost(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);
        return snapshot.data;
      },
    );
  }

  getPost(context) async {
    var doc = await userPostsRef
        .document(userId)
        .collection('posts')
        .document(postId)
        .get();
    var post = Post.fromDocument(doc);
    return Center(
      child: Scaffold(
        appBar: header(context, title: post.description),
        body: ListView(
          children: <Widget>[
            Container(
              child: post,
            )
          ],
        ),
      ),
    );
  }
}
