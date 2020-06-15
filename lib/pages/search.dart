import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:SuperSocial/pages/home.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:SuperSocial/models/user.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController textEditingController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(query) {
    Future<QuerySnapshot> result = usersRef
        .where('username', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = result;
    });
  }

  handleClear () {
    textEditingController.clear();
  }

  AppBar buildSearchField () {
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

  Container buildEmptySearchResults(context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset('assets/images/search.svg', height: 300.0,),
            Text('Find users', textAlign: TextAlign.center, style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 36.0
            ),)
          ],
        )
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
        List<Text> searchResults = [];
        snapshot.data.documents.forEach((document) {
          User user = User.fromDocument(document);
          searchResults.add(Text(user.username));
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: searchResultsFuture != null
          ? buildSearchResults(context)
          : buildEmptySearchResults(context),
    );
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("User Result");
  }
}
