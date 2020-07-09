import 'package:flutter/material.dart';

class MediaPreview {
  final Widget _widget;
  final String _text;

  MediaPreview(this._widget, this._text);
  String getText() {
    return _text;
  }

  Widget getWidget() {
    return _widget;
  }
}
