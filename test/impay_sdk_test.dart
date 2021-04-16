import 'package:flutter_test/flutter_test.dart';

import 'package:impay_sdk/impay_sdk.dart';

void main() {
  test('adds one to input values', () {
    final ImPayForm = ImPayForm(0, 0, null);
    expect(ImPayForm.addOne(2), 3);
  });
}
