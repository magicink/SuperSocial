import 'dart:io';
import 'package:SuperSocial/models/user.dart';
import 'package:SuperSocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Img;
import 'package:uuid/uuid.dart';
import 'home.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  File file;
  final imagePicker = ImagePicker();
  bool busy = false;
  String uuid = Uuid().v4();

  handleSubmit() async {
    setState(() {
      busy = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPost(
        mediaUrl: mediaUrl,
        caption: captionController.text,
        location: locationController.text);
  }

  compressImage() async {
    final tempDirectory = await getTemporaryDirectory();
    final tempPath = tempDirectory.path;
    Img.Image image = Img.decodeImage(file.readAsBytesSync());
    final compressImage = File('$tempPath/$uuid.jpg')
      ..writeAsBytesSync(Img.encodeJpg(image, quality: 75));
    setState(() {
      file = compressImage;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask task =
        storageReference.child('post_$uuid.jpg').putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    return await snapshot.ref.getDownloadURL();
  }

  createPost({mediaUrl, location, caption}) {
    final data = {
      'uuid': uuid,
      'userUid': widget.currentUser.uid,
      'username': widget.currentUser.username,
      'userPhotoUrl': widget.currentUser.photoUrl,
      'caption': caption,
      'location': location,
      'mediaUrl': mediaUrl,
      'timestamp': DateTime.now().toUtc()
    };
    userPostsRef
        .document(widget.currentUser.uid)
        .collection('posts')
        .document(uuid)
        .setData(data);
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      busy = false;
      uuid = Uuid().v4();
    });
  }

  Future handleImageFromGallery() async {
    Navigator.pop(context);
    final picked = await imagePicker.getImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  Future handleImageFromCamera() async {
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
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text('Image from camera'),
                ),
                onPressed: handleImageFromCamera,
              ),
              SimpleDialogOption(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text('Image from gallery'),
                ),
                onPressed: handleImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
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
                child: Text(
                  'Upload Image',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                onPressed: () => selectImage(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  getLocation () async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> location = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = location[0];
    locationController.text = "${placemark.locality}, ${placemark.country}";
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          'Post caption',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            color: Theme.of(context).primaryColorDark,
            child: Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: busy ? null : () => handleSubmit(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          busy ? linearProgress(context) : Text(''),
          Container(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover, image: FileImage(file))),
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
                controller: captionController,
                decoration: InputDecoration(
                    hintText: 'Caption', border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.deepOrange,
              size: 25.0,
            ),
            title: Container(
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                    hintText: 'Location', border: InputBorder.none),
              ),
            ),
          ),
          Container(
            child: RaisedButton.icon(
                onPressed: getLocation,
                icon: Icon(Icons.my_location),
                label: Text(
                  'Use current location',
                  style: TextStyle(color: Colors.white),
                )),
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
