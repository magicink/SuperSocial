import 'dart:async';

import 'package:SuperSocial/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formState = GlobalKey<FormState>();
  String username;

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: scaffoldKey,
      appBar: header(context, removeBack: false, title: 'Set up your profile'),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text("Username"),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: formState,
                    child: TextFormField(
                      autovalidate: true,
                      validator: (val) {
                        if (val.trim().length < 3 || val.trim().length > 12) {
                          return "Invalid length";
                        }
                        return null;
                      },
                      onSaved: (val) => username = val,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Username",
                          hintText: "Must be at least 3 characters"),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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

  submit() {
    if (formState.currentState.validate()) {
      formState.currentState.save();
      SnackBar snackBar = SnackBar(
        content: Text("Welcome $username"),
      );
      scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }
}
