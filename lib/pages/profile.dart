import 'package:SuperSocial/models/user.dart';
import 'package:SuperSocial/pages/edit_profile.dart';
import 'package:SuperSocial/widgets/header.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool busy = false;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<DocumentSnapshot> user;

  getUser() {
    setState(() {
      busy = true;
    });
    user = usersRef.document(widget.profileId).get();
    setState(() {
      busy = false;
    });
  }

  buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(count.toString(), style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(label, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),),
        )
      ],
    );
  }

  editProfile () async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) => EditProfile(userId: currentUser.uid,)
    ));
    getUser();
  }

  followUser () {}

  buildButton(context, {String label, Function onPressed}) {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: FlatButton(
        onPressed: onPressed,
        child: Container(
          alignment: Alignment.center,
          width: 250.0,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(5.0)
          ),
          padding: EdgeInsets.all(16.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  buildEditProfileButton (context) {
    if (widget.profileId == currentUser.uid) {
      return buildButton(context, label: 'Edit profile', onPressed: editProfile);
    }
    return buildButton(context, label: 'Follow', onPressed: followUser);
  }

  buildProfileHeader () {
    return FutureBuilder(
      future: user,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);
        User user = User.fromDocument(snapshot.data);
        return Padding (
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Theme.of(context).primaryColorDark,
                    backgroundImage: CachedNetworkImageProvider(
                      user.photoUrl
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn('Posts', 0),
                            buildCountColumn('Followers', 0),
                            buildCountColumn('Following', 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildEditProfileButton(context)
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(user.username, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
              ),
              Container(
                padding: EdgeInsets.only(top: 4.0),
                alignment: Alignment.centerLeft,
                child: Text(user.displayName),
              ),
              Container(
                padding: EdgeInsets.only(top: 4.0),
                alignment: Alignment.centerLeft,
                child: Text(user.bio),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Profile'),
      body: widget.profileId != null ? buildProfileHeader() : null,
    );
  }
}
