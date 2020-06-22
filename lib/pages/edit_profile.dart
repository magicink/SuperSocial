import 'package:SuperSocial/models/user.dart';
import 'package:SuperSocial/pages/home.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

class EditProfile extends StatefulWidget {
  final String userId;

  EditProfile({this.userId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool busy = false;
  User user;

  getUser() async {
    setState(() {
      busy = true;
    });
    DocumentSnapshot snapshot = await usersRef.document(widget.userId).get();
    user = User.fromDocument(snapshot);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
            )
          )
        ],
      ),
      body: busy || user == null ? circularProgress(context) : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
