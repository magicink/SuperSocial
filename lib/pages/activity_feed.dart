import 'package:SuperSocial/models/FeedItem.dart';
import 'package:SuperSocial/pages/home.dart';
import 'package:SuperSocial/widgets/header.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:flutter/material.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Activity Feed'),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return circularProgress(context);
            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }

  getActivityFeed() async {
    var snapshot = await feedRef
        .document(currentUser.uid)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .getDocuments();
    List<FeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(FeedItem.fromDocument(doc));
    });
    return feedItems;
  }
}
