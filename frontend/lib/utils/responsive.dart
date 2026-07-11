import 'package:flutter/material.dart';

bool isCompact(BuildContext context) {
  return MediaQuery.sizeOf(context).width < 360;
}
