import 'package:SuperSocial/models/post.dart';
import 'package:SuperSocial/pages/post_screen.dart';
import 'package:SuperSocial/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context, postId: post.id, userId: post.ownerId),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }

  showPost(BuildContext context, {String postId, String userId}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PostScreen(
        postId: postId,
        userId: userId,
      );
    }));
  }
}
