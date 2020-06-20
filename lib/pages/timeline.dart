import 'package:SuperSocial/widgets/header.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'home.dart';


class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
  }

//  getAdminUsers () async {
//    final QuerySnapshot admins = await usersRef
//        .where('isAdmin', isEqualTo: true)
//        .getDocuments();
//  }
//
//  getUsers () async {
//    final users = await usersRef.getDocuments();
//  }
//
//  getUserById(String id) async {
//    final user = await usersRef.document(id).get();
//  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, result) {
          if (!result.hasData) {
            return circularProgress(context);
          }
          final List<Text> children = result.data.documents
              .map((user) => Text(user['username']))
              .toList();
          return Container(
            child: ListView(
              children: children,
            ),
          );
        },
      ),
    );
  }
}
