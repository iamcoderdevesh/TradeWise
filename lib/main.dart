import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // Device Preview is a web-only development aid. It is installed only when
  // running on Flutter Web; on native platforms (Android, iOS, desktop) it is
  // never enabled, so application behavior there is completely unchanged.
  if (kIsWeb) {
    DevicePreview.enable();
  }
  runApp(const ProviderScope(child: TradeWiseApp()));
}
