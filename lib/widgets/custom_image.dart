import 'package:SuperSocial/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    placeholder: (context, url) => Padding(
      padding: EdgeInsets.all(20.0),
      child: circularProgress(context),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
