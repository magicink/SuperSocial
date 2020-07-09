import 'package:SuperSocial/models/MediaPreview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedItem extends StatelessWidget {
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

  MediaPreview buildMediaPreview () {
    Widget mediaPreview;
    String activityText;
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => print('tapped'),
        child: Container(
          height: 50.0,
          width:50.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(postMediaUrl)
                )
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    switch(type) {
      case 'like': {
        activityText = ' liked your post.';
      }
      break;
      case 'follow': {
        activityText = ' is following you.';
      }
      break;
      case 'comment': {
        activityText = ' commented on your post: $content';
      }
      break;
      default: {
        activityText = ' posted an unknown type: "$type"';
      }
    }

    return new MediaPreview(mediaPreview, activityText);
  }

  @override
  Widget build(BuildContext context) {
    MediaPreview mediaPreview = buildMediaPreview();
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white60,
        child: ListTile(
          title: GestureDetector(
            onTap: () => print('show profile'),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black
                ),
                children: [
                  TextSpan(text: username, style: TextStyle(
                    fontWeight: FontWeight.bold
                  )),
                  TextSpan(text: mediaPreview.getText())
                ]
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userPhotoUrl),
          ),
          trailing: mediaPreview.getWidget(),
        ),
      ),
    );
  }
}
