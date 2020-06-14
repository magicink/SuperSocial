import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  AppBar buildSearchField () {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: TextFormField(
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
            onPressed: () => print('Cleared'),
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: buildEmptySearchResults(context),
    );
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("User Result");
  }
}
