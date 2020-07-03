import 'package:SuperSocial/models/post.dart';
import 'package:SuperSocial/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('show image'),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
