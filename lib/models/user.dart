import 'package:cloud_firestore/cloud_firestore.dart';
class User {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String username;

  User({
    this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.username
  });

  factory User.fromDocument(DocumentSnapshot snapshot) {
    return User(
      uid: snapshot['uid'],
      displayName: snapshot['displayName'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      username: snapshot['username']
    );
  }
}
