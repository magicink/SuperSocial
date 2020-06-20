import 'package:SuperSocial/pages/activity_feed.dart';
import 'package:SuperSocial/pages/create_account.dart';
import 'package:SuperSocial/pages/profile.dart';
import 'package:SuperSocial/pages/search.dart';
import 'package:SuperSocial/pages/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:SuperSocial/models/user.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final CollectionReference usersRef = Firestore.instance.collection('users');
final CollectionReference userPostsRef = Firestore.instance.collection('userPosts');
final dateTimeUtc = DateTime.now().toUtc();
final StorageReference storageReference = FirebaseStorage.instance.ref();

User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isAuthenticated = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(context, account);
    }, onError: (error) => print('Error: $error'));

    firebaseAuth.onAuthStateChanged.listen((firebaseUser) async {
      getFirebaseUser(context, firebaseUser);
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  getFirebaseUser(context, firebaseUser) async {
    if (firebaseUser != null) {
      DocumentSnapshot userDocument = await usersRef.document(firebaseUser.uid).get();
      if (!userDocument.exists) {
        final username = await Navigator.push(context, MaterialPageRoute(
            builder: (context) => CreateAccount()
        ));
        await usersRef.document(firebaseUser.uid).setData({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'photoUrl': firebaseUser.photoUrl,
          'displayName': firebaseUser.displayName,
          'creationDate': dateTimeUtc,
          'lastSeen': dateTimeUtc,
          'username': username
        });
        userDocument = await usersRef.document(firebaseUser.uid).get();
      } else {
        usersRef.document(firebaseUser.uid).setData({
          'lastSeen': DateTime.now().toUtc()
        }, merge: true);
        userDocument = await usersRef.document(firebaseUser.uid).get();
      }
      currentUser = User.fromDocument(userDocument);
      setState(() {
        isAuthenticated = true;
      });
    }
  }

  handleSignIn(context, account) async {
    if (account != null) {
      GoogleSignInAuthentication googleAuthentication = await account.authentication;
      AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      );
      FirebaseUser firebaseUser = await firebaseAuth.signInWithCredential(credential);
    } else {
      setState(() {
        isAuthenticated = false;
      });
    }
  }

  signIn() {
    googleSignIn.signIn();
  }

  signOut() {
    googleSignIn.signOut();
    firebaseAuth.signOut();
    setState(() {
      isAuthenticated = false;
    });
  }

  handlePageChange (int index) {
    setState(() {
      pageIndex = index;
    });
  }

  onTap(int index) {
    pageController.animateToPage(index,
      duration: Duration(
        milliseconds: 250
      ),
      curve: Curves.easeInOut
    );
  }

  Scaffold buildAuthenticationScreen() {
    return Scaffold(
      key: scaffoldKey,
      body: PageView(
        children: <Widget>[
          RaisedButton(
            child: Text("Logout"),
            onPressed: signOut,
          ),
          ActivityFeed(),
          Upload(currentUser: currentUser,),
          Search(),
          Profile(profileId: currentUser?.uid,)
        ],
        controller: pageController,
        onPageChanged: handlePageChange,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: onTap,
        currentIndex: pageIndex,
        activeColor: Theme.of(context).primaryColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 35.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  Scaffold buildUnauthenticatedScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColorDark
            ]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'SuperSocial',
              style: TextStyle(
                fontFamily: 'Signatra', fontSize: 90.0, color: Colors.white
              ),
            ),
            GestureDetector(
              onTap: signIn,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuthenticated
        ? buildAuthenticationScreen()
        : buildUnauthenticatedScreen();
  }
}
