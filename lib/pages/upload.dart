import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  final imagePicker = ImagePicker();

  Future handleImageFromGallery () async {
    Navigator.pop(context);
    final picked = await imagePicker.getImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  Future handleImageFromCamera () async {
    Navigator.pop(context);
    final picked = await imagePicker.getImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  selectImage(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Image from camera'),
                onPressed: handleImageFromCamera,
              ),
              SimpleDialogOption(
                child: Text('Image from gallery'),
                onPressed: handleImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset('assets/images/upload.svg', height: 300.0),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: RaisedButton(
                color: Theme.of(context).primaryColorDark,
                padding: EdgeInsets.all(10.0),
                child: Text('Upload Image', textAlign: TextAlign.center, style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                ),),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
                onPressed: () => selectImage(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildSplashScreen();
  }
}
