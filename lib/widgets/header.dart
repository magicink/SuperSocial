import 'package:flutter/material.dart';

AppBar header(context, {removeBack = false, title = ''}) {
  return AppBar(
    automaticallyImplyLeading: removeBack,
    title: Text(
      title.isEmpty ? 'SuperSocial' : title,
      style: TextStyle(
          color: Colors.white,
          fontFamily: title.isEmpty ? 'Signatra' : '',
          fontSize: title.isEmpty ? 50.0 : 20.0),
    ),
    centerTitle: true,
  );
}
