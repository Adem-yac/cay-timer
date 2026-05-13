import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Runs before all tests. Keeps [GoogleFonts] from hitting the network in CI.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
