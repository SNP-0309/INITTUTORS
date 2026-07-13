// Smoke test placeholder.
//
// Real widget/interaction tests are added alongside features (development.md
// §8). This just asserts the shared constants are wired, keeping the default
// project test green without depending on any UI.

import 'package:flutter_test/flutter_test.dart';

import 'package:ams/shared/constants/app_constants.dart';

void main() {
  test('shared role enum is defined', () {
    expect(Role.values.length, 4);
  });
}
