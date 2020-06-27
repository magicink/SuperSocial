import 'package:cloud_firestore/cloud_firestore.dart';
class User {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String username;
  final String bio;

  User({
    this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.username,
    this.bio
  });

  factory User.fromDocument(DocumentSnapshot snapshot) {
    return User(
      uid: snapshot['uid'],
      displayName: snapshot['displayName'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      username: snapshot['username'],
      bio: snapshot['bio']
    );
  }
}
