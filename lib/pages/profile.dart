import 'package:SuperSocial/models/post.dart';
import 'package:SuperSocial/models/user.dart';
import 'package:SuperSocial/pages/edit_profile.dart';
import 'package:SuperSocial/pages/home.dart';
import 'package:SuperSocial/widgets/header.dart';
import 'package:SuperSocial/widgets/post_tile.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({Key key, this.profileId}): super(key: key);

  @override
  _ProfileState createState() => _ProfileState();

  static showProfile (context, { String profileId }) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Profile(profileId: profileId,);
    }));
  }
}

class _ProfileState extends State<Profile> {
  bool busy = false;
  int postCount = 0;
  List<Post> posts = [];
  bool showPostGrid = true;

  Future<DocumentSnapshot> user;
  Future<QuerySnapshot> userPosts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildPostOrientationToggle(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts()
        ],
      ),
    );
  }

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
              borderRadius: BorderRadius.circular(5.0)),
          padding: EdgeInsets.all(16.0),
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  buildEditProfileButton(context) {
    if (widget.profileId == currentUser.uid) {
      return buildButton(context,
          label: 'Edit profile', onPressed: editProfile);
    }
    return buildButton(context, label: 'Follow', onPressed: followUser);
  }

  buildPostOrientationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: showPostGrid ? null : togglePostView,
          icon: Icon(
            Icons.grid_on,
            color: showPostGrid ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        IconButton(
          onPressed: showPostGrid ? togglePostView : null,
          icon: Icon(
            Icons.list,
            color: showPostGrid ? Colors.grey : Theme.of(context).primaryColor,
          ),
        )
      ],
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: user,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Theme.of(context).primaryColorDark,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn('Posts', postCount),
                            buildCountColumn('Followers', 0),
                            buildCountColumn('Following', 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[buildEditProfileButton(context)],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
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

  Widget buildProfilePosts() {
    return FutureBuilder(
      future: userPosts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);

        if (posts.isEmpty) {
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
                Padding(padding: EdgeInsets.only(top: 20.0),),
                Text('No content', style: TextStyle(
                  fontSize: 22.0
                ),)
              ],
            ),
          );
        }

        List<GridTile> gridTiles = [];
        posts.forEach((post) {
          gridTiles.add(GridTile(
            child: PostTile(post: post),
          ));
        });
        return showPostGrid
            ? GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: gridTiles,
              )
            : Column(
                children: posts,
              );
      },
    );
  }

  editProfile() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(
                  userId: currentUser.uid,
                )));
    getUser();
  }

  followUser() {}

  void getProfilePost() {
    setState(() {
      busy = true;
    });
    userPosts = userPostsRef
        .document(widget.profileId)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    userPosts.then((results) {
      setState(() {
        postCount = results.documents.length;
        posts = results.documents.map((document) {
          return Post.fromDocument(document);
        }).toList();
        busy = false;
      });
      return null;
    });
  }

  getUser() {
    setState(() {
      busy = true;
    });
    user = usersRef.document(widget.profileId).get();
    user.then((result) {
      setState(() {
        busy = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getProfilePost();
  }

  togglePostView() {
    setState(() {
      showPostGrid = !showPostGrid;
    });
  }
}
