import 'package:flutter_windowmanager/flutter_windowmanager.dart';

void disableScreenCapture() async {
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
}

void enableScreenCapture() async {
  await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
}