import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top -
      kToolbarHeight;
}
