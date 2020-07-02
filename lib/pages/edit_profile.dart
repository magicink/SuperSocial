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
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool busy = false;
  User user;
  bool displayNameIsValid = true;
  bool bioIsValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Edit Profile'),
        actions: <Widget>[
          IconButton(
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(
                Icons.done,
                size: 30.0,
              ))
        ],
      ),
      body: busy || user == null
          ? circularProgress(context)
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildTextField(
                                displayNameController, displayNameIsValid,
                                label: 'Display name',
                                hint: 'Update display name',
                                error: 'Display name is too short'),
                            buildTextField(bioController, bioIsValid,
                                label: 'Bio',
                                error: 'Bio can only be 100 characters')
                          ],
                        ),
                      ),
                      RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        onPressed: updateProfile,
                        child: Text(
                          'Update',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          onPressed: logout,
                          label: Text(
                            'Logout',
                            style: TextStyle(fontSize: 20.0, color: Colors.red),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget buildTextField(TextEditingController controller, bool isValid,
      {String label, String hint, String error}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            label,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
              hintText: hint, errorText: isValid ? null : error),
        )
      ],
    );
  }

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
  void initState() {
    super.initState();
    getUser();
  }

  void logout() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  void updateProfile() {
    setState(() {
      displayNameIsValid = displayNameController.text.trim().length > 3;
      bioIsValid = bioController.text.trim().length <= 100;
    });
    if (displayNameIsValid && bioIsValid) {
      usersRef.document(widget.userId).updateData({
        "displayName": displayNameController.text.trim(),
        "bio": bioController.text.trim()
      });
      SnackBar snackbar = SnackBar(
        content: Text('Profile updated'),
      );
      scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }
}
