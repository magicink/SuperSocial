import 'package:SuperSocial/models/user.dart';
import 'package:SuperSocial/pages/home.dart';
import 'package:SuperSocial/pages/profile.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColorDark,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => Profile.showProfile(context, profileId: this.user.uid),
            child: ListTile(
              contentPadding: EdgeInsets.all(5.0),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Theme.of(context).accentColor,
          )
        ],
      ),
    );
  }
}

class _SearchState extends State<Search> {
  TextEditingController textEditingController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: buildSearchField(),
      body: searchResultsFuture != null
          ? buildSearchResults(context)
          : buildEmptySearchResults(context),
    );
  }

  Container buildEmptySearchResults(context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
          child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/search.svg',
            height: 300.0,
          ),
          Text(
            'Find users',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 36.0),
          )
        ],
      )),
    );
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          hintText: "Search for a user",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 25.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              size: 25.0,
            ),
            onPressed: handleClear,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  FutureBuilder buildSearchResults(context) {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((document) {
          User user = User.fromDocument(document);
          UserResult userResult = UserResult(user);
          searchResults.add(userResult);
        });
        return ListView(
          padding: EdgeInsets.all(5.0),
          children: searchResults,
        );
      },
    );
  }

  handleClear() {
    textEditingController.clear();
  }

  handleSearch(query) {
    Future<QuerySnapshot> result = usersRef
        .where('username', isGreaterThanOrEqualTo: query)
        .orderBy('username', descending: true)
        .getDocuments();
    setState(() {
      searchResultsFuture = result;
    });
  }
}
