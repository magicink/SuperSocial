import 'dart:io';
import 'package:SuperSocial/models/user.dart';
import 'package:SuperSocial/pages/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

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
            ),
          ],
        ),
      ),
    );
  }

  clearImage () {
    setState(() {
      file = null;
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: clearImage,
        ),
        title: Text(
          'Post caption',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            color: Theme.of(context).primaryColorDark,
            child: Text('Post', style: TextStyle(color: Colors.white),),
            onPressed: () => print('post'),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file)
                  )
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.currentUser != null
                  ? CachedNetworkImageProvider(widget.currentUser.photoUrl)
                  : null,
            ),
            title: Container(
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Caption',
                    border: InputBorder.none
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.deepOrange, size: 25.0,),
            title: Container(
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Location',
                    border: InputBorder.none
                ),
              ),
            ),
          ),
          Container(
            child: RaisedButton.icon(
              onPressed: null,
              icon: Icon(
                Icons.my_location
              ),
              label: Text(
                'Use current location',
                style: TextStyle(color: Colors.white),
              )
            ),
            alignment: Alignment.center,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
